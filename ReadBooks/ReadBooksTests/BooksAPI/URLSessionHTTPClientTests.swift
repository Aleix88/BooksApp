//
//  URLSessionHTTPClientTests.swift
//  ReadBooksTests
//
//  Created by Aleix Diaz Baggerman on 7/8/23.
//

//public protocol HTTPClient {
//    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void)
//}

import XCTest
import ReadBooks

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {}
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_init_noRequestIsSent() {
        URLProtocolSpy.registerHandler()
        
        let session = URLSession.shared
        _ = URLSessionHTTPClient(session: session)
        
        XCTAssertEqual(URLProtocolSpy.requests, [])
        
        URLProtocolSpy.unregisterHandler()
    }

}

class URLProtocolSpy: URLProtocol {
    static var requests = [URLRequest]()
    
    static func registerHandler() {
        URLProtocol.registerClass(Self.self)
    }
    
    static func unregisterHandler() {
        URLProtocol.unregisterClass(Self.self)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        requests.append(request)
        return true
    }
}


