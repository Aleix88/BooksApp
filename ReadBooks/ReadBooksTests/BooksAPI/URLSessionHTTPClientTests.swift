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
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let request = URLRequest(url: url)
        session.dataTask(with: request) { _, _, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(Data(), HTTPURLResponse()))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_init_noRequestIsSent() {
        URLProtocolSpy.startInterceptingRequests()
        
        _ = URLSessionHTTPClient()
        
        XCTAssertEqual(URLProtocolSpy.requestsURLs, [])
        
        URLProtocolSpy.stopInterceptingRequests()
    }
    
    func test_get_requestIsSent() {
        URLProtocolSpy.startInterceptingRequests()

        let expect = expectation(description: "Wait for get completion")
        let url = URL(string: "https://www.some-url.com")!
        let sut = URLSessionHTTPClient()

        sut.get(url: url) { _ in
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1.0)
        XCTAssertEqual(URLProtocolSpy.requestsURLs, [url])

        URLProtocolSpy.stopInterceptingRequests()
    }
    
    func test_get_failsOnRequestError() {
        URLProtocolSpy.startInterceptingRequests()

        let expect = expectation(description: "Wait for get completion")
        let url = URL(string: "https://www.some-url.com")!
        let sut = URLSessionHTTPClient()
        let expectedError = NSError(domain: "", code: 0)
        URLProtocolSpy.setStub(expectedError)

        sut.get(url: url) { result in
            switch result {
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            case .success:
                XCTFail("Expecting failing and got success")
            }
            expect.fulfill()
        }

        wait(for: [expect], timeout: 1.0)

        URLProtocolSpy.stopInterceptingRequests()
    }
}

class URLProtocolSpy: URLProtocol {
    static var requestsURLs = [URL?]()
    static var stub: Error?
    
    static func setStub(_ error: Error) {
        stub = error
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(Self.self)
    }
    
    static func stopInterceptingRequests() {
        requestsURLs = []
        stub = nil
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
        if let error = Self.stub {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}


