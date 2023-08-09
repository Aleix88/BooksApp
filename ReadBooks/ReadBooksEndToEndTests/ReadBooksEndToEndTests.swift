//
//  ReadBooksEndToEndTests.swift
//  ReadBooksEndToEndTests
//
//  Created by Aleix Diaz Baggerman on 9/8/23.
//

import XCTest
import ReadBooks

final class ReadBooksEndToEndTests: XCTestCase {

    func test_search_successWithBooks() {
        switch searchResult() {
        case .success(let books)?:
            XCTAssertEqual(books, expectedBooks())
        case .failure(let error)?:
            XCTFail("Expected success and got failure with \(error)")
        default:
            XCTFail("Expection success and got no result")
        }
    }
    
    // MARK: Helpers
    
    private func makeBookSearcher() -> BookSearcher {
        let baseURL = URL(string: "https://dev-q81384830o46004.api.raw-labs.com")!
        let urlFactory = BookSearchURLFactory(baseURL: baseURL)
        let client = URLSessionHTTPClient()
        let bookSearcher = RemoteBookSearcher(client: client, urlFactory: urlFactory)
        return bookSearcher
    }
    
    private func searchResult() -> BookSearchResult? {
        let expectation = expectation(description: "Wait for search completion")
        let bookSearcher = makeBookSearcher()
        
        var receivedResult: BookSearchResult?
        bookSearcher.search(input: "Some input") { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        return receivedResult
    }

    private func expectedBooks() -> [Book] {
        [
            Book(
                id: UUID(uuidString: "a4a20aee-d2bb-4870-9f72-6353389889d4")!,
                name: "El imperio final",
                author: "Brandon Sanderson",
                imageURL: URL(string: "https://books.google.es/books/publisher/content?id=xKk4AwAAQBAJ&hl=es&pg=PP1&img=1&zoom=3&bul=1&sig=ACfU3U1VEl36I200TBcyiqXBjSP1_VSBIg&w=1280")!
            ),
            Book(
                id: UUID(uuidString: "95988043-a429-4578-b7d3-f3d28404e61d")!,
                name: "Citónica",
                author: "Brandon Sanderson",
                imageURL: URL(string: "https://books.google.es/books/publisher/content?id=gdhJEAAAQBAJ&hl=es&pg=PP1&img=1&zoom=3&bul=1&sig=ACfU3U38ijQX2ukpWmpZqhOWJLSwym5Rdw&w=1280")!
            ),
            Book(
                id: UUID(uuidString: "f6592456-d857-45dd-a8c3-b842e9401578")!,
                name: "El nombre del viento",
                author: "Patrick rothfuss",
                imageURL: nil
            )
        ]
    }
}
