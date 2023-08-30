//
//  Post.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import Foundation

struct Post: Codable, Identifiable {
    let id: Int
    var title: String
    var body: String
    let userId: Int
}
