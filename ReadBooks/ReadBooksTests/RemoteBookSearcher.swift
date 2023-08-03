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
    func search(input: String) {
        HTTPClient.shared.get(url: URL(string: "https://www.some-url.com")!)
    }
}

final class RemoteBookSearcherTests: XCTestCase {

    // ARRANGE - ACT - ASSERT
    func test_init_noneRequestIsSent() {
        let client = HTTPClient.shared
        _ = RemoteBookSearcher()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_onSearch_requestIsSent() {
        let client = HTTPClient.shared
        let sut = RemoteBookSearcher()
        
        sut.search(input: "")
        
        XCTAssertNotNil(client.requestedURL)
    }

}
