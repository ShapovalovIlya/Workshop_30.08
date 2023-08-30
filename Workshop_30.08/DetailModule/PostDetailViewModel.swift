//
//  PostDetailViewModel.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import Foundation
import OSLog
import Combine

final class PostDetailViewModel: ObservableObject {
    //MARK: - Private properties
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PostDetailViewModel.self)
    )
    private let apiClient: ApiClient
    
    //MARK: - Public properties
    @Published var title: String = .init()
    @Published var body: String = .init()
    
    //MARK: - init(_:)
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    //MARK: - Public methods
    func sendNewPost() {
        
    }
}
