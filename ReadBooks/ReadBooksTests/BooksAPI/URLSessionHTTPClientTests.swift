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
    
    func get(url: URL, completion: @escaping () -> Void) {
        let request = URLRequest(url: url)
        session.dataTask(with: request) { _, _, _ in
            completion()
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_init_noRequestIsSent() {
        URLProtocolSpy.startInterceptingRequests()
        
        let session = URLSession.shared
        _ = URLSessionHTTPClient(session: session)
        
        XCTAssertEqual(URLProtocolSpy.requestsURLs, [])
        
        URLProtocolSpy.stopInterceptingRequests()
    }
    
    func test_get_requestIsSent() {
        URLProtocolSpy.startInterceptingRequests()

        let expect = expectation(description: "Wait for get completion")
        let url = URL(string: "https://www.some-url.com")!
        let session = URLSession.shared
        let sut = URLSessionHTTPClient(session: session)

        sut.get(url: url) {
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1.0)
        XCTAssertEqual(URLProtocolSpy.requestsURLs, [url])

        URLProtocolSpy.stopInterceptingRequests()
    }
}

class URLProtocolSpy: URLProtocol {
    static var requestsURLs = [URL?]()
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(Self.self)
    }
    
    static func stopInterceptingRequests() {
        requestsURLs = []
        URLProtocol.unregisterClass(Self.self)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        requestsURLs.append(request.url)
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}


