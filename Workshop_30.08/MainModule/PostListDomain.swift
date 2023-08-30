//
//  PostListDomain.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import Foundation
import Combine

struct PostListDomain {
    //MARK: - State
    struct State {
        var posts: [Post] = .init()
        var errorMessage: String = .init()
        var dataLoadingStatus: DataLoadingStatus = .none
        var showAddPostView = false
        var showError = false
    }
    
    //MARK: - Action
    enum Action {
        case onAppeared
        case addButtonTap
        case tapOnPost(Post)
        case dismissAlert
        case _fetchPostsRequest
        case _fetchPostsResponse(Result<[Post], Error>)
    }
    
    enum DataLoadingStatus {
        case none
        case loading
        case error
    }
    
    //MARK: - Dependencies
    let apiClient: ApiClient
    
    //MARK: - Reducer
    func reduce(_ state: inout State, action: Action) -> AnyPublisher<Action, Never> {
        switch action {
        case .onAppeared:
            if state.dataLoadingStatus != .loading {
                return Just(._fetchPostsRequest).eraseToAnyPublisher()
            }
            
        case .addButtonTap:
            state.showAddPostView = true
            
        case .tapOnPost(let post):
            break
            
        case .dismissAlert:
            state.showError = false
            
        case ._fetchPostsRequest:
            state.dataLoadingStatus = .loading
            return requestPosts()
            
        case let ._fetchPostsResponse(.success(posts)):
            state.posts = posts
            state.dataLoadingStatus = .none
            
        case let ._fetchPostsResponse(.failure(error)):
            state.showError = true
            state.errorMessage = error.localizedDescription
            state.dataLoadingStatus = .error
        }
        
        return Empty().eraseToAnyPublisher()
    }
    
    func requestPosts() -> AnyPublisher<Action, Never> {
        apiClient.getPostsPublisher()
            .map { Action._fetchPostsResponse(.success($0)) }
            .catch { Just(._fetchPostsResponse(.failure($0))) }
            .eraseToAnyPublisher()
    }
    
    static let alertStore = Store(
        initialState: State(
            posts: [],
            errorMessage: "Some fucking error!",
            dataLoadingStatus: .error,
            showAddPostView: false,
            showError: true
        ),
        reducer: Self(apiClient: .init()).reduce(_:action:)
    )
}
