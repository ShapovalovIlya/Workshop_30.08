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
    @StateObject var viewModel: PostListViewModel
    
    var body: some Scene {
        WindowGroup {
            PostListView(viewModel: viewModel)
        }
    }
    
    init() {
        let viewModel = PostListViewModel(apiClient: self.apiClient)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}
