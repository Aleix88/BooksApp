//
//  RemoteBookSearcherTests.swift
//  ReadBooksTests
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import XCTest
import ReadBooks

class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()

    func get(url: URL) {
        requestedURLs.append(url)
    }
}

class SearchURLFactorySpy: SearchURLAbstractFactory {
    var input: String?
    
    func create(input: String) -> URL? {
        self.input = input
        return nil
    }
}

final class RemoteBookSearcherTests: XCTestCase {

    // ARRANGE - ACT - ASSERT
    func test_init_noRequestIsSent() {
        let (_, client) = makeSut()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_onSearchWithEmptyInput_noRequestIsSent() {
        let (sut, client) = makeSut()
        
        sut.search(input: "")
        sut.search(input: "    ")
        sut.search(input: "\n")
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_onSearch_requestIsSent() {
        let url = URL(string: "https://www.some-url.com")!
        let (sut, client) = makeSut(url: url)

        sut.search(input: "Some book name")
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_onSearchTwice_twoRequestAreSent() {
        let url = URL(string: "https://www.some-url.com")!
        let (sut, client) = makeSut(url: url)
        
        sut.search(input: "Some book name")
        sut.search(input: "Another book name")
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_onSearch_inputIsInjectedToURLFactory() {
        let (sut, _, urlFactory) = makeSut()
        
        sut.search(input: "Some book name")
        
        XCTAssertEqual(urlFactory.input, "Some book name")
    }

    // MARK: Helpers
    func makeSut(url: URL = URL(string: "https://www.some-url.com")!) -> (RemoteBookSearcher, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBookSearcher(client: client, url: url, urlFactory: SearchURLFactorySpy())
        return (sut, client)
    }
    
    func makeSut(baseUrl: URL = URL(string: "https://www.some-url.com")!) -> (RemoteBookSearcher, HTTPClientSpy, SearchURLFactorySpy) {
        let client = HTTPClientSpy()
        let urlFactory = SearchURLFactorySpy()
        let sut = RemoteBookSearcher(client: client, url: baseUrl, urlFactory: urlFactory)
        return (sut, client, urlFactory)
    }
}
