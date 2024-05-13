import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift



import Foundation

enum FashionStyle: String, CaseIterable {
    case streetwear = "Streetwear"
    case casual = "Casual"
    case formal = "Formal"


    var rawValueAsInt: Int {
        switch self {
        case .streetwear: return 1
        case .casual: return 2
        case .formal: return 3

        }
    }
}

enum Category: String, CaseIterable { // Options for clothing categories -Sharvay Ajit
    case tShirts = "T-Shirts"
    case shoes = "Shoes"

}

struct UploadPage: View {
    @State private var selectedImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var userPosts: [Post] = []
    @State private var caption: String = ""
    @State private var selectedStyle: FashionStyle?
    @State private var selectedCategory: Category?
    @State private var isStyleDropdownVisible: Bool = false
    @State private var isCategoryDropdownVisible: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 5)
                        .padding(.bottom, 20)
                } else {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }

                Button("Select Photo") {
                    showImagePicker.toggle()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.bottom, 20)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $selectedImage)
                }

                TextField("Add a caption...", text: $caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                NavigationLink(destination: styleSelectionView, isActive: $isStyleDropdownVisible) {
                                    EmptyView()
                                }
                                Button(action: {
                                    isStyleDropdownVisible.toggle()
                                }) {
                                    Text("Select Style: \(selectedStyle?.rawValue ?? "")")
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                NavigationLink(destination: categorySelectionView, isActive: $isCategoryDropdownVisible) {
                                    EmptyView()
                                }
                                Button(action: {
                                    isCategoryDropdownVisible.toggle()
                                }) {
                                    Text("Select Category: \(selectedCategory?.rawValue ?? "")") // Button to choose clothing category - Sharvay Ajit
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                Button("Upload") {
                    uploadPhoto()
                }
                .padding()
                .foregroundColor(.blue)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
    }

    private func uploadPhoto() {
        guard let selectedImage = selectedImage, let userId = Auth.auth().currentUser?.uid else {
            // Handle case where no image is selected or user ID is unavailable
            return
        }

        // Upload to Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let photoRef = storageRef.child("user_photos/\(userId)/\(UUID().uuidString).jpg")

        if let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            photoRef.putData(imageData, metadata: metadata) { (_, error) in
                if let error = error {
                    // Handle error uploading photo
                    print("Error uploading photo: \(error)")
                } else {
                    // Get the download URL for the photo
                    photoRef.downloadURL { (url, error) in
                        guard let photoUrl = url else {
                            
                            return
                        }

                        savePhotoInfoToFirestore(userId: userId, photoUrl: photoUrl)
                    }
                }
            }
        }
    }

    private func savePhotoInfoToFirestore(userId: String, photoUrl: URL) {
        do {
            let db = Firestore.firestore()

            let postDocument = db.collection("users").document(userId).collection("posts").document() //added category field - Sharvay Ajit
            let postInfo: [String: Any] = [
                "imageUrl": photoUrl.absoluteString,
                "userId": userId,
                "likes": 0,
                "commentCount": 0, // Initialize with 0
                "caption": caption,
                "style": selectedStyle?.rawValueAsInt ?? 0,
                "category": selectedCategory?.rawValue ?? ""
            ]

            postDocument.setData(postInfo) { error in
                if let error = error {
                    // Handle error saving post info to Firestore
                    print("Error saving post info to Firestore: \(error)")
                } else {
                    // Create a Post instance with required parameters
                    let newPost = Post(
                        pid: postDocument.documentID as? String ?? "",
                        imageUrl: postInfo["imageUrl"] as? String ?? "",
                        userId: postInfo["userId"] as? String ?? "",
                        likes: postInfo["likes"] as? Int ?? 0,
                        commentCount: postInfo["commentCount"] as? Int ?? 0
                    )

                    // Append the new post to the userPosts array
                    userPosts.append(newPost)

                    print("Post uploaded and info saved successfully")
                }
            }
        } catch {
            print("Failed to save with error \(error.localizedDescription)")
        }
    }
    
    private var styleSelectionView: some View {
            VStack {
                ForEach(FashionStyle.allCases, id: \.self) { style in
                    Button(action: {
                        selectedStyle = style
                        isStyleDropdownVisible = false
                    }) {
                        Text(style.rawValue)
                            .foregroundColor(selectedStyle == style ? .blue : .black)
                            .padding()
                    }
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                }
            }
            .padding()
            .navigationBarTitle("Select Style", displayMode: .inline)
        }
    //New view to select the category -Sharvay Ajit
    private var categorySelectionView: some View {
            VStack {
                ForEach(Category.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        isCategoryDropdownVisible = false
                    }) {
                        Text(category.rawValue)
                            .foregroundColor(selectedCategory == category ? .blue : .black)
                            .padding()
                    }
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                }
            }
            .padding()
            .navigationBarTitle("Select Category", displayMode: .inline)
        }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}

