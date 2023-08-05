//
//  Book.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 3/8/23.
//

import Foundation

public struct Book: Equatable {
    public let id: UUID
    public let name: String
    public let author: String
    public let imageURL: URL?
    
    public init(id: UUID, name: String, author: String, imageURL: URL?) {
        self.id = id
        self.name = name
        self.author = author
        self.imageURL = imageURL
    }
}
