import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var photoItems: [PhotoItem] = []

    @State private var showName = false
    @State private var selectedPhoto: PhotoItem?

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Photo Picker")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)

                PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared()) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Select Photos")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
                .onChange(of: selectedItems) {
                    Task {
                        await loadImages(from: selectedItems)
                        selectedItems = [] // Avoid duplicates
                    }
                }

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(photoItems) { item in
                            Button {
                                selectedPhoto = item
                                showName = true
                            } label: {
                                item.image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.bottom)
                        }
                    }
                    .padding()
                }
            }
            .overlay(
                ZStack {
                    if showName, let selectedPhoto {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        VStack(spacing: 16) {
                            Text("Name this image")
                                .font(.headline)
                            TextField("Enter name", text: binding(for: selectedPhoto))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)

                            HStack {
                                Button("Cancel") {
                                    showName = false
                                }
                                Button("Save") {
                                    showName = false
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding()
                    }
                }
            )
        }
    }

    func binding(for photo: PhotoItem) -> Binding<String> {
        guard let index = photoItems.firstIndex(where: { $0.id == photo.id }) else {
            return .constant("")
        }
        return $photoItems[index].name
    }

    func loadImages(from items: [PhotosPickerItem]) async {
        var newItems: [PhotoItem] = []

        for (index, item) in items.enumerated() {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                let name = "Photo \(photoItems.count + index + 1)"
                let photoItem = PhotoItem(name: name, uiImage: uiImage)
                newItems.append(photoItem)
            }
        }

        photoItems.append(contentsOf: newItems)
    }
}
