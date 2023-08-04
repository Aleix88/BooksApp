//
//  RemoteBookSearcher.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import Foundation

public protocol HTTPClient {
    func get(url: URL)
}

public protocol SearchURLAbstractFactory {
    func create(input: String) -> URL?
}

public class RemoteBookSearcher {
    
    private let client: HTTPClient
    private let urlFactory: SearchURLAbstractFactory
    
    public init(client: HTTPClient, urlFactory: SearchURLAbstractFactory) {
        self.client = client
        self.urlFactory = urlFactory
    }
    
    public func search(input: String) {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let url = urlFactory.create(input: input)
        else { return }
        client.get(url: url)
    }
}
