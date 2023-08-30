//
//  Store.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import Foundation
import OSLog
import Combine

// MVVM
/*
 SwiftUI -> View; UIKit -> UIViewController
 
 ViewModel -> Bussines logic
 
 Service -> API
 
 */


final class Store<State, Action>: ObservableObject {
    //MARK: - Private properties
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Store.self)
    )
    private var cancelable: Set<AnyCancellable> = .init()
    private var reducer: (inout State, Action) -> AnyPublisher<Action, Never>
    
    //MARK: - Public properties
    @Published private(set) var state: State
    
    //MARK: - init(_:)
    init(
        initialState: State,
        reducer: @escaping (inout State, Action) -> AnyPublisher<Action, Never>
    ) {
        self.state = initialState
        self.reducer = reducer
    }
    
    //MARK: - Public methods
    func send(_ action: Action) {
        reducer(&state, action)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &cancelable)
    }
    
//    func fetchPostsCompletion() {
//        apiClient.getPosts { result in
//            DispatchQueue.main.async { [weak self] in
//                switch result {
//                case let .success(posts):
//                    self?.posts = posts
//                case let .failure(error):
//                    self?.showError = true
//                    self?.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
    
//    func awaitFetchPosts() async {
//        do {
//            self.posts = try await apiClient.getPosts()
//        } catch {
//            self.showError = true
//            self.errorMessage = error.localizedDescription
//        }
//    }
}
