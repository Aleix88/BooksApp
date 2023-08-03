//
//  RemoteBookSearcherTests.swift
//  ReadBooksTests
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import XCTest
import ReadBooks

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    var requestedURLs = [URL]()

    func get(url: URL) {
        requestedURL = url
        requestedURLs.append(url)
    }
}

final class RemoteBookSearcherTests: XCTestCase {

    // ARRANGE - ACT - ASSERT
    func test_init_noneRequestIsSent() {
        let (_, client) = makeSut()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_onSearch_requestIsSent() {
        let (sut, client) = makeSut()

        sut.search(input: "")
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    func test_onSearchTwice_twoRequestAreSent() {
        let url = URL(string: "https://www.some-url.com")!
        let (sut, client) = makeSut(url: url)
        
        sut.search(input: "")
        sut.search(input: "")
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    // MARK: Helpers
    func makeSut(url: URL = URL(string: "https://www.some-url.com")!) -> (RemoteBookSearcher, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBookSearcher(client: client, url: url)
        return (sut, client)
    }
}
