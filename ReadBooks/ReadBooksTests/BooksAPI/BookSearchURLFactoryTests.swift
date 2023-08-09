//
//  BookSearchURLFactory.swift
//  ReadBooksTests
//
//  Created by Aleix Diaz Baggerman on 9/8/23.
//

import XCTest

class BookSearchURLFactory {
    func create(input: String) -> URL? {
        return nil
    }
}

final class BookSearchURLFactoryTests: XCTestCase {

    func test_create_returnsNilWithInvalidInput() {
        let sut = BookSearchURLFactory()
        XCTAssertNil(sut.create(input: ""))
        XCTAssertNil(sut.create(input: "    "))
        XCTAssertNil(sut.create(input: "\n\n\n"))
    }

}
