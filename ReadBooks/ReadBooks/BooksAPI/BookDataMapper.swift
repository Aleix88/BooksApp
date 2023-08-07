//
//  BookDataMapper.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 7/8/23.
//

import Foundation

internal final class BooksDataMapper {
    private struct Root: Decodable {
        let books: [BookDTO]
    }

    private struct BookDTO: Decodable {
        private let id: UUID
        private let name: String
        private let author: String
        private let image: URL?
        
        var book: Book {
            Book(id: id, name: name, author: author, imageURL: image)
        }
    }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteBookSearcher.Result {
        if response.statusCode == 200,
           let root = try? JSONDecoder().decode(Root.self, from: data) {
            let books = root.books.map(\.book)
            return .success(books)
        } else {
            return .failure(.invalidData)
        }
    }
}
