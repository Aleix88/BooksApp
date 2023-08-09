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
        XCTAssertEqual(makeSUT().create(input: ""), searchURL(withInput: ""))
        XCTAssertEqual(makeSUT().create(input: " "), searchURL(withInput: "%20"))
        XCTAssertEqual(makeSUT().create(input: "\n"), searchURL(withInput: "%0A"))
    }

    func test_create_returnsURLWithValidInput() {
        XCTAssertEqual(makeSUT().create(input: "Input"), searchURL(withInput: "Input"))
    }
    
    // MARK: Helpers
    private func makeSUT() -> SearchURLAbstractFactory {
        BookSearchURLFactory(baseURL: baseURL())
    }
    
    private func baseURL() -> URL {
        URL(string: "https://www.somebaseurl.com")!
    }
    
    private func searchURL(withInput input: String) -> URL {
        URL(string: baseURL().absoluteString + "/books?q=\(input)")!
    }
}
