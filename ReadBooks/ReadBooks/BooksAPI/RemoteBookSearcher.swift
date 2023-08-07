//
//  RemoteBookSearcher.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public protocol SearchURLAbstractFactory {
    func create(input: String) -> URL?
}

public class RemoteBookSearcher {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case invalidInput
    }
    
    public enum Result: Equatable {
        case success([Book])
        case failure(Error)
    }
    
    private let client: HTTPClient
    private let urlFactory: SearchURLAbstractFactory
    
    public init(client: HTTPClient, urlFactory: SearchURLAbstractFactory) {
        self.client = client
        self.urlFactory = urlFactory
    }
    
    public func search(input: String, completion: @escaping (Result) -> Void) {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let url = urlFactory.create(input: input)
        else {
            completion(.failure(.invalidInput))
            return
        }
        
        client.get(url: url) { result in
            switch result {
            case let .success(data, response):
                let result = BooksDataMapper.map(data, response)
                completion(result)
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
}

private class BooksDataMapper {
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
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteBookSearcher.Result {
        if response.statusCode == 200,
           let root = try? JSONDecoder().decode(Root.self, from: data) {
            let books = root.books.map(\.book)
            return .success(books)
        } else {
            return .failure(.invalidData)
        }
    }
}
