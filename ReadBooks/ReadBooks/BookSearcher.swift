//
//  BookSearcher.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import Foundation

enum BookSearchResult {
    case success([Book])
    case error(Error)
}

protocol BookSearcher {
    func search(input: String, completion: (BookSearchResult) -> Void)
}
