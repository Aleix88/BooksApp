//
//  BookSearchURLFactory.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 9/8/23.
//

import Foundation

public final class BookSearchURLFactory {
    private let baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    public func create(input: String) -> URL? {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.path = "/books"
        urlComponents?.queryItems = [URLQueryItem(name: "q", value: input)]
        return urlComponents?.url
    }
}
