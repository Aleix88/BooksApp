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
        return nil
    }
}

final class BookSearchURLFactoryTests: XCTestCase {

    func test_create_returnsNilWithInvalidInput() {
        let sut = BookSearchURLFactory(baseURL: URL(string: "https://www.somebaseurl.com")!)
        XCTAssertNil(sut.create(input: ""))
        XCTAssertNil(sut.create(input: "    "))
        XCTAssertNil(sut.create(input: "\n\n\n"))
    }

}
