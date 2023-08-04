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

final class RemoteBookSearcherTests: XCTestCase {

    // ARRANGE - ACT - ASSERT
    func test_init_noRequestIsSent() {
        let (_, client, _) = makeSut()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_onSearchWithEmptyInput_noRequestIsSent() {
        let (sut, client, _) = makeSut()
        
        sut.search(input: "")
        sut.search(input: "    ")
        sut.search(input: "\n")
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_onSearch_requestIsSent() {
        let (sut, client, urlFactory) = makeSut()

        sut.search(input: "Some book name")
        sut.search(input: "Another book name")

        XCTAssertEqual(client.requestedURLs.count, 2)
        XCTAssertEqual(client.requestedURLs, urlFactory.urls)
    }
    
    func test_onSearch_inputIsInjectedToURLFactory() {
        let (sut, _, urlFactory) = makeSut()
        
        sut.search(input: "Some book name")
        
        XCTAssertEqual(urlFactory.input, "Some book name")
    }

    // MARK: Helpers
    
    func makeSut(baseUrl: URL = URL(string: "https://www.some-url.com")!) -> (RemoteBookSearcher, HTTPClientSpy, SearchURLFactoryMock) {
        let client = HTTPClientSpy()
        let urlFactory = SearchURLFactoryMock()
        let sut = RemoteBookSearcher(client: client, url: baseUrl, urlFactory: urlFactory)
        return (sut, client, urlFactory)
    }
}
