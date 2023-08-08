//
//  URLSessionHTTPClientTests.swift
//  ReadBooksTests
//
//  Created by Aleix Diaz Baggerman on 7/8/23.
//

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
        URLProtocolStub.startInterceptingRequests()
        
        _ = URLSessionHTTPClient()
        
        XCTAssertFalse(URLProtocolStub.didHandleAnyRequest)
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_get_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()

        let expect = expectation(description: "Wait for get completion")
        let url = URL(string: "https://www.some-url.com")!
        let sut = URLSessionHTTPClient()
        let expectedError = NSError(domain: "", code: 0)
        URLProtocolStub.setStub(expectedError)

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

        URLProtocolStub.stopInterceptingRequests()
    }
}

class URLProtocolStub: URLProtocol {
    static var didHandleAnyRequest = false
    static private var stub: Error?

    static func setStub(_ error: Error) {
        stub = error
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(Self.self)
    }
    
    static func stopInterceptingRequests() {
        stub = nil
        didHandleAnyRequest = false
        URLProtocol.unregisterClass(Self.self)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        didHandleAnyRequest = true
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


