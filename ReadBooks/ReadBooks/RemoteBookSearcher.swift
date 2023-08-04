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

public class RemoteBookSearcher {
    
    private let client: HTTPClient
    private let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func search(input: String) {
        guard !input.isEmpty else {
            return
        }
        client.get(url: url)
    }
}
