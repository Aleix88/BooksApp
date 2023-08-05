//
//  Book.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import Foundation

public struct Book: Equatable {
    let id: String
    let name: String
    let author: String
    let imageURL: URL?
}
