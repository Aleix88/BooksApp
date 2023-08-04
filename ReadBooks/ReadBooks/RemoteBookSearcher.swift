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
    private let url: URL
    private let urlFactory: SearchURLAbstractFactory
    
    public init(client: HTTPClient, url: URL, urlFactory: SearchURLAbstractFactory) {
        self.client = client
        self.url = url
        self.urlFactory = urlFactory
    }
    
    public func search(input: String) {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        let _ = urlFactory.create(input: input)
        client.get(url: url)
    }
}
