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
        
        var sutError: RemoteBookSearcher.Error?
        sut.search(input: "Some book name") { error in
            sutError = error
        }
        client.completeWithError()
        
        XCTAssertEqual(sutError, .connectivity)
    }

    // MARK: Helpers
    
    func makeSut(urlFactory: SearchURLAbstractFactory = SearchURLFactoryMock()) -> (RemoteBookSearcher, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBookSearcher(client: client, urlFactory: urlFactory)
        return (sut, client)
    }
}

class HTTPClientSpy: HTTPClient {
    var messages = [(url: URL, completion: (Error) -> Void)]()
    var requestedURLs: [URL] {
        messages.map(\.url)
    }

    func get(url: URL, completion: @escaping (Error) -> Void) {
        messages.append((url, completion))
    }
    
    func completeWithError() {
        messages[0].completion(NSError(domain: "", code: 0))
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
