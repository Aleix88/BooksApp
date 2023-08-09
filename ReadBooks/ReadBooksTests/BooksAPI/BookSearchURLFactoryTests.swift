//
//  BookSearchURLFactory.swift
//  ReadBooksTests
//
//  Created by Aleix Diaz Baggerman on 9/8/23.
//

import XCTest

class BookSearchURLFactory {
    let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func create(input: String) -> URL? {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.path = "/books"
        urlComponents?.queryItems = [URLQueryItem(name: "q", value: input)]
        return urlComponents?.url
    }
}

final class BookSearchURLFactoryTests: XCTestCase {

    func test_create_returnsNilWithInvalidInput() {
        let sut = BookSearchURLFactory(baseURL: URL(string: "https://www.somebaseurl.com")!)
        XCTAssertNil(sut.create(input: ""))
        XCTAssertNil(sut.create(input: "    "))
        XCTAssertNil(sut.create(input: "\n\n\n"))
    }

    func test_create_returnsURLWithValidInput() {
        let url = URL(string: "https://www.somebaseurl.com")!
        let sut = BookSearchURLFactory(baseURL: url)
        XCTAssertEqual(sut.create(input: "Input"), URL(string: "https://www.somebaseurl.com/books?q=Input"))
    }
}
