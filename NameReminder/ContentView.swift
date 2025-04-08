//
//  ContentView.swift
//  NameReminder
//
//  Created by Hadi Al zayer on 10/10/1446 AH.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var processedImages: [Image] = []
   

    // Grid with 2 columns and spacing
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                               
                               PhotosPicker(
                                   selection: $selectedItems,
                                   maxSelectionCount: 10,
                                   matching: .images
                               ) {
                                   HStack {
                                       Image(systemName: "photo.badge.plus")
                                           .font(.title)
                                       Text("Select Photos")
                                           .fontWeight(.medium)
                                   }
                                   .padding()
                                   .frame(maxWidth: .infinity)
                                   .background(Color.blue.opacity(0.1))
                                   .clipShape(RoundedRectangle(cornerRadius: 12))
                               }
                               .onChange(of: selectedItems) {
                                   Task {
                                       await loadImages()
                                   }
                               }
                               .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(processedImages.indices, id: \.self) { index in
                            processedImages[index]
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - 32, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .clipped()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Photo Picker")
        }
        .onChange(of: selectedItems) {
            Task {
                await loadImages()
            }
        }
    }

    func loadImages() async {
        var newImages: [Image] = []

        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                let image = Image(uiImage: uiImage)
                newImages.append(image)
            }
        }

        processedImages = newImages
    }

}

#Preview {
    ContentView()
}
