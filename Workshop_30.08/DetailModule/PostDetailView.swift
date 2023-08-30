//
//  PostDetailView.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import SwiftUI
import Combine

struct AddPostDomain {
    //MARK: - State
    typealias State = Post
    
    //MARK: - Action
    enum Action {
        case setTitle(String)
        case setBody(String)
        case sendPostButtonTap
        case sendPostResponse(Result<Post, Error>)
    }
    
    //MARK: - Dependencies
    let apiClient: ApiClient
    
    func reduce(state: inout State, action: Action) -> AnyPublisher<Action, Never> {
        switch action {
        case .setTitle(let title):
            let newTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            state.title = newTitle
            
        case .setBody(let body):
            state.body = body
            
        case .sendPostButtonTap:
            return apiClient.sendNew(post: state)
                .map { Action.sendPostResponse(.success($0)) }
                .catch { Just(.sendPostResponse(.failure($0))) }
                .eraseToAnyPublisher()
                
        case let .sendPostResponse(.success(post)):
            print(post)
            
        case let .sendPostResponse(.failure(error)):
            print(error)
        }
        return Empty().eraseToAnyPublisher()
    }
    
    static let previewStore = Store(
        initialState: Post(id: 1, title: "", body: "", userId: 1),
        reducer: Self(apiClient: .init()).reduce(state:action:)
    )
}

struct PostDetailView: View {
    @ObservedObject var store: Store<AddPostDomain.State, AddPostDomain.Action>
    
    var body: some View {
        List {
            Section("Title") {
                TextField("", text: bindTitle())
            }
            Section("Body") {
                TextEditor(text: bindBody())
            }
            Section {
                Button("Send post") {
                    store.send(.sendPostButtonTap)
                }
            }
        }
        .navigationTitle("New post")
    }
    
    func bindTitle() -> Binding<String> {
        .init(
            get: { store.state.title },
            set: { store.send(.setTitle($0)) }
        )
    }
    
    func bindBody() -> Binding<String> {
        .init(
            get: { store.state.body },
            set: { store.send(.setBody($0)) }
        )
    }
}

#Preview {
    NavigationStack {
        PostDetailView(store: AddPostDomain.previewStore)
    }
}
