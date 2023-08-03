//
//  RemoteBookSearcherTests.swift
//  ReadBooksTests
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import XCTest

class HTTPClient {
    static let shared = HTTPClient()
    var requestedURL: URL?
    
    private init() {}
    
    func get(url: URL) {
        requestedURL = url
    }
}

class RemoteBookSearcher {
    
    let client: HTTPClient
    let url: URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func search(input: String) {
        client.get(url: url)
    }
}

final class RemoteBookSearcherTests: XCTestCase {

    // ARRANGE - ACT - ASSERT
    func test_init_noneRequestIsSent() {
        let client = HTTPClient.shared
        _ = RemoteBookSearcher(client: client, url: URL(string: "https://www.some-url.com")!)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_onSearch_requestIsSent() {
        let client = HTTPClient.shared
        let sut = RemoteBookSearcher(client: client, url: URL(string: "https://www.some-url.com")!)

        sut.search(input: "")
        
        XCTAssertNotNil(client.requestedURL)
    }

}
