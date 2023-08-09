//
//  BookSearchURLFactory.swift
//  ReadBooksTests
//
//  Created by Aleix Diaz Baggerman on 9/8/23.
//

import XCTest
import ReadBooks

final class BookSearchURLFactoryTests: XCTestCase {

    func test_create_returnsNilWithInvalidInput() {
        let sut = BookSearchURLFactory(baseURL: baseURL())
        XCTAssertEqual(sut.create(input: ""), searchURL(withInput: ""))
        XCTAssertEqual(sut.create(input: " "), searchURL(withInput: "%20"))
        XCTAssertEqual(sut.create(input: "\n"), searchURL(withInput: "%0A"))
    }

    func test_create_returnsURLWithValidInput() {
        let sut = BookSearchURLFactory(baseURL: baseURL())
        XCTAssertEqual(sut.create(input: "Input"), searchURL(withInput: "Input"))
    }
    
    // MARK: Helpers
    private func baseURL() -> URL {
        URL(string: "https://www.somebaseurl.com")!
    }
    
    private func searchURL(withInput input: String) -> URL {
        URL(string: baseURL().absoluteString + "/books?q=\(input)")!
    }
}
