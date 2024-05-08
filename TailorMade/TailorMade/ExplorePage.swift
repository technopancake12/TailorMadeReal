//
//  ExplorePage.swift
//  Tailor Made
//
//  Created by Hoang Le on 2/4/24.
//

import SwiftUI

struct ExplorePage: View {
    @StateObject private var viewModel = ExplorePageViewModel()
    @State private var searchText = ""
    @State private var selectedPost: Post?
    @State private var selectedUserID: String = "" // Change the type to String
    @State private var navigateToSelectedProfilePage = false
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, viewModel: viewModel, onUserSelected: { userID in
                    selectedUserID = userID // Update selectedUserID directly
                    navigateToSelectedProfilePage = true
                })
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVGrid(columns: [GridItem(spacing: 1), GridItem(spacing: 1), GridItem(spacing: 1)]) {
                            ForEach(viewModel.images) { image in
                                AsyncImage(url: image.url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let loadedImage):
                                        loadedImage
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: (UIScreen.main.bounds.width - 40) / 3, height: 120)
                                            .onTapGesture {
                                                selectedPost = Post(
                                                    pid: image.pid,
                                                    imageUrl: image.url.absoluteString,
                                                    userId: image.userId,
                                                    likes: image.likes,
                                                    commentCount: image.commentCount
                                                )
                                            }
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: (UIScreen.main.bounds.width - 40) / 3, height: 120)
                                    }
                                }
                                .onTapGesture {
                                    selectedPost = Post(
                                        pid: image.pid,
                                        imageUrl: image.url.absoluteString,
                                        userId: image.userId,
                                        likes: image.likes,
                                        commentCount: image.commentCount
                                    )
                                }
                                .onAppear {
                                    if image == viewModel.images.last {
                                        viewModel.populateData(page: viewModel.currentPage + 1)
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        viewModel.populateData(page: 1)
                    }
                }
            }
            .sheet(item: $selectedPost) { post in
                CombinedInstagramPostView(post: post)
            }.background(
                NavigationLink(
                    destination: SelectedProfilePage(selectedUserID: $selectedUserID), // Pass selectedUserID directly
                    isActive: $navigateToSelectedProfilePage,
                    label: { EmptyView() }
                )
            )
        }
    }
}

    
    // previewing page
    struct ExplorePage_Previews: PreviewProvider {
        static var previews: some View {
            ExplorePage()
        }
    }
    
struct SearchBar: View {
    @Binding var text: String
    let viewModel: ExplorePageViewModel
    let onUserSelected: (String) -> Void // Closure to handle user selection
    
    @State private var isSearching = false
    
    init(text: Binding<String>, viewModel: ExplorePageViewModel, onUserSelected: @escaping (String) -> Void) {
        self._text = text
        self.viewModel = viewModel
        self.onUserSelected = onUserSelected // Initialize closure parameter
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: $text, onCommit: {
                    isSearching = true
                    viewModel.searchUserByUsername(username: text)
                })
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 0))
                .background(Color(.systemGray5))
                .cornerRadius(8)
                
                Spacer()
                
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(8)
                }
                .padding(.trailing, 8)
                .opacity(text.isEmpty ? 0 : 1)
            }
            .padding(.horizontal, 8)
            .background(Color(.systemBackground))
            
            // Autocomplete suggestions
            if isSearching {
                List(viewModel.autocompleteSuggestions.filter { $0.lowercased().hasPrefix(text.lowercased()) }, id: \.self) { suggestion in
                    Button(action: {
                        text = suggestion
                        onUserSelected(text) // Pass the selected suggestion
                        isSearching = false
                        text = "" // Clear the search bar after selection
                    }) {
                        Text(suggestion)
                    }
                }
                .frame(maxHeight: 150)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 3)
            }
        }
    }
}



