//
//  XCTestCase+MemoryLeaks.swift
//  ReadBooksTests
//
//  Created by Aleix Diaz Baggerman on 8/8/23.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeaks(
        for instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "Instance should have been deallocated. Potential memory leak!",
                file: file,
                line: line
            )
        }
    }
}
