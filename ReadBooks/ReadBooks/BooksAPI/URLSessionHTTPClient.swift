//
//  URLSessionHTTPClient.swift
//  ReadBooks
//
//  Created by Aleix Diaz Baggerman on 8/8/23.
//

import Foundation

public class URLSessionHTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let request = URLRequest(url: url)
        session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
