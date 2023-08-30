//
//  Endpoint.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import Foundation

struct Endpoint {
    let path: String
    var queryItems: [URLQueryItem] = .init()
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "jsonplaceholder.typicode.com"
        
        guard let url = components.url else {
            preconditionFailure("Unable to create url from: \(components)")
        }
        return url
    }
    
    static let posts = Self(path: "/posts")
}
