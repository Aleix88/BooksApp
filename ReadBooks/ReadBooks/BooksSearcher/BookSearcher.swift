//
//  BookSearcher.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import Foundation

public enum BookSearchResult<Error> {
    case success([Book])
    case failure(Error)
}

extension BookSearchResult: Equatable where Error: Equatable {}

protocol BookSearcher {
    associatedtype Error
    func search(input: String, completion: @escaping (BookSearchResult<Error>) -> Void)
}
