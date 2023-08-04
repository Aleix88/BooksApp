//
//  RemoteBookSearcher.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data?, HTTPURLResponse)
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
        client.get(url: url) { result in
            switch result {
            case .success(_, _):
                completion(.invalidData)
            case .failure(_):
                completion(.connectivity)
            }
        }
    }
}
