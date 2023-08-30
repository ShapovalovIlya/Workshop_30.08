//
//  Post.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import Foundation

struct Post: Codable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}
