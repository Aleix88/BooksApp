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
    
    func test_onSearchWithInvalidInput_noRequestIsSent() {
        let (sut, client) = makeSut()
        
        sut.search(input: "")
        sut.search(input: "    ")
        sut.search(input: "\n")
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_onSearch_requestIsSent() {
        let urlFactory = SearchURLFactoryMock()
        let (sut, client) = makeSut(urlFactory: urlFactory)
        
        sut.search(input: "Some book name")
        sut.search(input: "Another book name")

        XCTAssertEqual(client.requestedURLs.count, 2)
        XCTAssertEqual(client.requestedURLs, urlFactory.urls)
    }
    
    func test_onSearch_inputIsInjectedToURLFactory() {
        let urlFactory = SearchURLFactoryMock()
        let (sut, _) = makeSut(urlFactory: urlFactory)
        
        sut.search(input: "Some book name")
        
        XCTAssertEqual(urlFactory.input, "Some book name")
    }
    
    func test_onSearchWithNilURLFromFactory_noRequestIsSent() {
        let urlFactory = NilSearchURLFactoryStub()
        let (sut, client) = makeSut(urlFactory: urlFactory)
        
        sut.search(input: "Some book name")
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_onSearch_deliversErrorOnClientError() {
        let (sut, client) = makeSut()
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            client.completeWithError()
        }
    }
    
    func test_onSearchWithStatusCodeNot200_deliversInvalidDataError() {
        let (sut, client) = makeSut()
        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.completeWithHTTPResponse(statusCode: statusCode, at: index)
            }
        }
    }
    
    func test_onSearchWithStatusCode200AndInvalidJson_deliversInvalidDataError() {
        let (sut, client) = makeSut()
        let invalidJson = Data("Invalid json".utf8)
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            client.completeWithHTTPResponse(statusCode: 200, data: invalidJson, at: 0)
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
        toCompleteWith result: RemoteBookSearcher.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var results = [RemoteBookSearcher.Result]()
        sut.search(input: "Some book name") { results.append($0) }
        action()
        
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
    
    func completeWithHTTPResponse(statusCode: Int, data: Data? = nil, at index: Int) {
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
