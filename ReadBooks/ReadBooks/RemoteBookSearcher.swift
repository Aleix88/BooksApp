//
//  RemoteBookSearcher.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import Foundation

public protocol HTTPClient {
    func get(url: URL, completion: @escaping (Error) -> Void)
}

public protocol SearchURLAbstractFactory {
    func create(input: String) -> URL?
}

public class RemoteBookSearcher {
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    private let client: HTTPClient
    private let urlFactory: SearchURLAbstractFactory
    
    public init(client: HTTPClient, urlFactory: SearchURLAbstractFactory) {
        self.client = client
        self.urlFactory = urlFactory
    }
    
    public func search(input: String, completion: @escaping (Error) -> Void = { _ in }) {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let url = urlFactory.create(input: input)
        else { return }
        client.get(url: url) { _ in
            completion(.connectivity)
        }
    }
}
