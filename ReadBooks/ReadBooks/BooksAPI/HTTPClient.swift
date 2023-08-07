//
//  HTTPClient.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 7/8/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
