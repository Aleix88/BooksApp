//
//  BookSearcher.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import Foundation

public enum BookSearchResult{
    case success([Book])
    case failure(Error)
}

public protocol BookSearcher {
    func search(input: String, completion: @escaping (BookSearchResult) -> Void)
}
