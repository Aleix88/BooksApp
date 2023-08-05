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

    // ARRANGE - ACT - ASSERT
    func test_init_noRequestIsSent() {
        let (_, client) = makeSut()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_onSearch_withInvalidInput_noRequestIsSentAndFailsWithInvalidInput() {
        let (sut, client) = makeSut()
        
        expect(sut, withInput: "", toCompleteWith: .failure(.invalidInput))
        expect(sut, withInput: "    ", toCompleteWith: .failure(.invalidInput))
        expect(sut, withInput: "\n", toCompleteWith: .failure(.invalidInput))
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
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            client.completeWithError()
        }
    }
    
    func test_onSearch_withStatusCodeNot200_deliversInvalidDataError() {
        let (sut, client) = makeSut()
        let samples = [199, 201, 300, 400, 500]
        let validJson = Data("{ \"books\": [] }".utf8)

        samples.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
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
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            client.completeWithHTTPResponse(statusCode: 200, data: invalidJson, at: 0)
        }
    }

    func test_onSearch_withStatusCode200AndValidJson_deliversEmptyArray() {
        let (sut, client) = makeSut()
        let validJson = Data("{ \"books\": [] }".utf8)

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
        let book1JSON: [String: Any] = [
            "id": book1.id.uuidString,
            "name": book1.name,
            "author": book1.author
        ]
        let book2JSON: [String: Any] = [
            "id": book2.id.uuidString,
            "name": book2.name,
            "author": book2.author,
            "image": book2.imageURL!.absoluteString
        ]
        let rootJSON: [String: Any] = [
            "books": [book1JSON, book2JSON]
        ]
        let data = try! JSONSerialization.data(withJSONObject: rootJSON)
        
        expect(sut, toCompleteWith: .success([book1, book2])) {
            client.completeWithHTTPResponse(statusCode: 200, data: data, at: 0)
        }
    }

    // MARK: Helpers
    
    func makeSut(urlFactory: SearchURLAbstractFactory = SearchURLFactoryMock()) -> (RemoteBookSearcher, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBookSearcher(client: client, urlFactory: urlFactory)
        return (sut, client)
    }
    
    func expect(
        _ sut: RemoteBookSearcher,
        withInput input: String = "Some book name",
        toCompleteWith result: RemoteBookSearcher.Result,
        when action: (() -> Void)? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var results = [RemoteBookSearcher.Result]()
        sut.search(input: input) { results.append($0) }
        action?()
        
        XCTAssertEqual(results, [result], file: file, line: line)
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
