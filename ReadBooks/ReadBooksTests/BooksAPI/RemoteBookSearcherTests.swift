//
//  RemoteBookSearcherTests.swift
//  ReadBooksTests
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import XCTest
import ReadBooks

class NilSearchURLFactoryStub: SearchURLAbstractFactory {
    func create(input: String) -> URL? {
        return nil
    }
}

final class RemoteBookSearcherTests: XCTestCase {

    func test_init_noRequestIsSent() {
        let (_, client) = makeSut()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_onSearch_withInvalidInput_noRequestIsSentAndFailsWithInvalidInput() {
        let (sut, client) = makeSut()
        
        expect(sut, withInput: "", toCompleteWith: failure(.invalidInput))
        expect(sut, withInput: "    ", toCompleteWith: failure(.invalidInput))
        expect(sut, withInput: "\n", toCompleteWith: failure(.invalidInput))
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_onSearch_requestIsSent() {
        let urlFactory = SearchURLFactoryMock()
        let (sut, client) = makeSut(urlFactory: urlFactory)
        
        sut.search(input: "Some book name") { _ in }
        sut.search(input: "Another book name") { _ in }

        XCTAssertEqual(client.requestedURLs.count, 2)
        XCTAssertEqual(client.requestedURLs, urlFactory.urls)
    }
    
    func test_onSearch_inputIsInjectedToURLFactory() {
        let urlFactory = SearchURLFactoryMock()
        let (sut, _) = makeSut(urlFactory: urlFactory)
        
        sut.search(input: "Some book name") { _ in }
        
        XCTAssertEqual(urlFactory.input, "Some book name")
    }
    
    func test_onSearch_withNilURLFromFactory_noRequestIsSent() {
        let urlFactory = NilSearchURLFactoryStub()
        let (sut, client) = makeSut(urlFactory: urlFactory)
        
        sut.search(input: "Some book name") { _ in }
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_onSearch_deliversErrorOnClientError() {
        let (sut, client) = makeSut()
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            client.completeWithError()
        }
    }
    
    func test_onSearch_withStatusCodeNot200_deliversInvalidDataError() {
        let (sut, client) = makeSut()
        let samples = [199, 201, 300, 400, 500]
        let validJson = makeBooksJSON()

        samples.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                client.completeWithHTTPResponse(
                    statusCode: statusCode,
                    data: validJson,
                    at: index
                )
            }
        }
    }
    
    func test_onSearch_withStatusCode200AndInvalidJson_deliversInvalidDataError() {
        let (sut, client) = makeSut()
        let invalidJson = Data("Invalid json".utf8)
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            client.completeWithHTTPResponse(statusCode: 200, data: invalidJson, at: 0)
        }
    }

    func test_onSearch_withStatusCode200AndValidJson_deliversEmptyArray() {
        let (sut, client) = makeSut()
        let validJson = makeBooksJSON()

        expect(sut, toCompleteWith: .success([])) {
            client.completeWithHTTPResponse(statusCode: 200, data: validJson, at: 0)
        }
    }
    
    func test_onSearch_withStatusCode200AndJsonWithBooks_deliversBooks() {
        let (sut, client) = makeSut()
        let book1 = Book(
            id: UUID(),
            name: "Book 1",
            author: "Author 1",
            imageURL: nil
        )
        let book2 = Book(
            id: UUID(),
            name: "Book 2",
            author: "Author 2",
            imageURL: URL(string: "https://www.google.es")!
        )
        let booksJson = makeBooksJSON(books: [book1, book2])
        
        expect(sut, toCompleteWith: .success([book1, book2])) {
            client.completeWithHTTPResponse(statusCode: 200, data: booksJson, at: 0)
        }
    }
    
    func test_onSearch_whenSutDeallocates_completionIsNotCalled() {
        var (sut, client): (RemoteBookSearcher?, HTTPClientSpy) = makeSut()
        
        var didCallCompletion = false
        sut?.search(input: "Some book name", completion: { _ in
            didCallCompletion = true
        })
        sut = nil
        client.completeWithHTTPResponse(statusCode: 200, data: makeBooksJSON(), at: 0)
        
        XCTAssertFalse(didCallCompletion)
    }

    // MARK: Helpers
    
    func makeSut(urlFactory: SearchURLAbstractFactory = SearchURLFactoryMock()) -> (RemoteBookSearcher, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBookSearcher(client: client, urlFactory: urlFactory)
        trackMemoryLeaks(for: sut)
        trackMemoryLeaks(for: client)
        return (sut, client)
    }
    
    func makeBooksJSON(books: [Book] = []) -> Data {
        let booksJson = books.reduce([]) { partialResult, book in
            let bookJSON: [String: Any?] = [
                "id": book.id.uuidString,
                "name": book.name,
                "author": book.author,
                "image": book.imageURL?.absoluteString
            ]
            let jsonItem: [String: Any] = bookJSON.compactMapValues { $0 }
            return partialResult + [jsonItem]
        }
        let root = ["books": booksJson]
        return try! JSONSerialization.data(withJSONObject: root)
    }
    
    func failure(_ error: RemoteBookSearcher.Error) -> RemoteBookSearcher.Result {
        return .failure(error)
    }
    
    func expect(
        _ sut: RemoteBookSearcher,
        withInput input: String = "Some book name",
        toCompleteWith expectedResult: RemoteBookSearcher.Result,
        when action: (() -> Void)? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = expectation(description: "Wait for search completion")
        
        sut.search(input: input) { result in
            switch (result, expectedResult) {
            case (.success(let books), .success(let expectedBooks)):
                XCTAssertEqual(books, expectedBooks, file: file, line: line)
            case (.failure(let error as RemoteBookSearcher.Error), .failure(let expectedError as RemoteBookSearcher.Error)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            default:
                XCTFail("Expecting \(expectedResult) and got \(result)")
            }
            expectation.fulfill()
        }
        action?()
        
        wait(for: [expectation], timeout: 1)
    }
}

class HTTPClientSpy: HTTPClient {
    var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    var requestedURLs: [URL] {
        messages.map(\.url)
    }

    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func completeWithError() {
        messages[0].completion(.failure(NSError(domain: "", code: 0)))
    }
    
    func completeWithHTTPResponse(statusCode: Int, data: Data, at index: Int) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success(data, response))
    }
}

class SearchURLFactoryMock: SearchURLAbstractFactory {
    var input: String?
    var urls = [URL?]()
    
    func create(input: String) -> URL? {
        let url = URL(string: "https://www.factory-url.com")
        self.input = input
        self.urls.append(url)
        return url
    }
}
