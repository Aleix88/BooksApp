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

    func get(url: URL) {
        requestedURL = url
    }
}

final class RemoteBookSearcherTests: XCTestCase {

    // ARRANGE - ACT - ASSERT
    func test_init_noneRequestIsSent() {
        let client = HTTPClientSpy()
        _ = RemoteBookSearcher(client: client, url: URL(string: "https://www.some-url.com")!)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_onSearch_requestIsSent() {
        let client = HTTPClientSpy()
        let sut = RemoteBookSearcher(client: client, url: URL(string: "https://www.some-url.com")!)

        sut.search(input: "")
        
        XCTAssertNotNil(client.requestedURL)
    }

}
