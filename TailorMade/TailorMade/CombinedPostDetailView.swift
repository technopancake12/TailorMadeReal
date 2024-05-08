import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestoreSwift

struct CombinedInstagramPostView: View {
    var post: Post
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if post.userId == viewModel.currentUser?.id {
            InstagramPostView(post: post)
        } else {
            ViewerInstagramPostView(post: post)
        }
    }
}
