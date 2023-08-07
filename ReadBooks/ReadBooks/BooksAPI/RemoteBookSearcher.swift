//
//  RemoteBookSearcher.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import Foundation

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
                completion(BooksDataMapper.map(data, response))
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
}
