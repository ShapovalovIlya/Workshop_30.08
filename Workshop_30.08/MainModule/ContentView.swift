//
//  ContentView.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.posts) { post in
                    VStack {
                        Text(post.title)
                            .font(.title)
                        Text(post.body)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .navigationTitle("Posts")
            .task {
                viewModel.fetchPostsCompletion()
            }
            .alert(
                "Error",
                isPresented: $viewModel.showError) {
                    Button("Ok", role: .cancel) {}
                } message: {
                    Text(viewModel.errorMessage)
                }

        }
    }
}

#Preview {
    ContentView(viewModel: .init(apiClient: .init()))
}
