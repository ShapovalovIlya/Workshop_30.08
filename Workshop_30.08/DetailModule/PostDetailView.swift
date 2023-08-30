//
//  PostDetailView.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import SwiftUI

struct PostDetailView: View {
    @ObservedObject var viewModel: PostDetailViewModel
    
    var body: some View {
        List {
            Section("Title") {
                TextField("", text: $viewModel.title)
            }
            Section("Body") {
                TextEditor(text: $viewModel.body)
            }
            Section {
                Button("Send post") {
                    viewModel.sendNewPost()
                }
            }
        }
        .navigationTitle("New post")
    }
}

#Preview {
    NavigationStack {
        PostDetailView(viewModel: .init(apiClient: .init()))
    }
}
