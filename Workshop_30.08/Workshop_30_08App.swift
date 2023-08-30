//
//  Workshop_30_08App.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import SwiftUI

@main
struct Workshop_30_08App: App {
    let apiClient = ApiClient()
    @StateObject var viewModel: Store<PostListDomain.State, PostListDomain.Action>
    
    var body: some Scene {
        WindowGroup {
            PostListView(store: viewModel)
        }
    }
    
    init() {
        let viewModel = Store(
            initialState: PostListDomain.State(),
            reducer: PostListDomain(apiClient: self.apiClient).reduce(_:action:)
        )
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}
