//
//  SearchURLAbstractFactory.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 7/8/23.
//

import Foundation

public protocol SearchURLAbstractFactory {
    func create(input: String) -> URL?
}
