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
    
    struct UnexpectedValuesRepresentation: Error {}
    
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let request = URLRequest(url: url)
        session.dataTask(with: request) { _, _, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()

    }

    func test_init_noRequestIsSent() {
        _ = makeSUT()
        XCTAssertFalse(URLProtocolStub.didHandleAnyRequest)
    }
    
    func test_get_correctRequestIsSent() {
        let url = anyURL()
        let expectation = expectation(description: "Wait for get completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod?.uppercased(), "GET")
        }
        makeSUT().get(url: url) { _ in expectation.fulfill() }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_get_failsOnRequestError() {
        let expectedError = NSError(domain: "", code: 0)
        let error = resultErrorFor(data: nil, response: nil, error: expectedError)
        XCTAssertEqual((error as? NSError)?.domain, expectedError.domain)
        XCTAssertEqual((error as? NSError)?.code, expectedError.code)
    }
    
    func test_get_failsOnAllNilValues() {
        let error = resultErrorFor(data: nil, response: nil, error: nil)
        XCTAssertNotNil(error)
    }
    
    // MARK: Helpers
    func anyURL() -> URL {
        URL(string: "https://www.some-url.com")!
    }
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }
    
    func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let expectation = expectation(description: "Wait for get completion")
        URLProtocolStub.setStub(data: data, response: response, error: error)
        
        var receivedError: Error?
        makeSUT(file: file, line: line).get(url: anyURL()) { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Expection failure and got \(result)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)

        return receivedError
    }
}

class URLProtocolStub: URLProtocol {
    static var didHandleAnyRequest = false
    static private var requestsObserver: ((URLRequest) -> Void)?
    static private var stub: Stub?
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    static func setStub(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) {
        stub = Stub(data: data, response: response, error: error)
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        requestsObserver = observer
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(Self.self)
    }
    
    static func stopInterceptingRequests() {
        requestsObserver = nil
        stub = nil
        didHandleAnyRequest = false
        URLProtocol.unregisterClass(Self.self)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        didHandleAnyRequest = true
        requestsObserver?(request)
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let data = Self.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = Self.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = Self.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}


