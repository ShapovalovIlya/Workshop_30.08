//
//  PostListView.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import SwiftUI

struct PostsList: View {
    let posts: [Post]
    
    var body: some View {
        List {
            ForEach(posts) { post in
                VStack {
                    Text(post.title)
                        .font(.title2)
                    Text(post.body)
                        .font(.caption)
                }
                .onTapGesture {
                    
                }
            }
        }
    }
}

struct PostListView: View {
    @ObservedObject var store: Store<PostListDomain.State, PostListDomain.Action>
    
    var body: some View {
        NavigationStack {
            VStack {
                switch store.state.dataLoadingStatus {
                case .none:
                    PostsList(posts: store.state.posts)
                case .loading:
                    ProgressView()
                case .error:
                    EmptyView()
                }
            }
            .navigationTitle("Posts")
            .onAppear {
                store.send(.onAppeared)
            }
            .alert(
                "Error",
                isPresented: bindAlert()
            ) {
                Button("Ok", role: .cancel) {}
            } message: {
                Text(store.state.errorMessage)
            }
            .toolbar(content: {
                Button("Add post") {
                    
                }
            })
        }
    }
    
    func bindAlert() -> Binding<Bool> {
        .init(
            get: { store.state.showError },
            set: { _ in store.send(.dismissAlert) }
        )
    }
}

#Preview("Alert") {
    PostListView(store: PostListDomain.alertStore )
}

//#Preview("Alert") {
//    let vm = PostListViewModel(apiClient: .init())
//    vm.alertState()
//    return PostListView(viewModel: vm)
//}
