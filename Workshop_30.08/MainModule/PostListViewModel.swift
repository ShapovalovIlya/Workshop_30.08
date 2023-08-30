//
//  PostListViewModel.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import Foundation
import OSLog
import Combine

final class PostListViewModel: ObservableObject {
    //MARK: - Private properties
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PostListViewModel.self)
    )
    private let apiClient: ApiClient
    private var cancelable: Set<AnyCancellable> = .init()
    
    //MARK: - Public properties
    @Published var posts: [Post] = .init()
    @Published var showError = false
    @Published var errorMessage: String = .init()
    
    //MARK: - init(_:)
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    //MARK: - Public methods
    func fetchPostsPublisher() {
        apiClient.getPostsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.showError = true
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { posts in
                self.posts = posts
            }
            .store(in: &cancelable)

    }
    
    func fetchPostsCompletion() {
        apiClient.getPosts { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case let .success(posts):
                    self?.posts = posts
                case let .failure(error):
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func awaitFetchPosts() async {
        do {
            self.posts = try await apiClient.getPosts()
        } catch {
            self.showError = true
            self.errorMessage = error.localizedDescription
        }
    }
}
