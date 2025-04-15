//
//  PhotoItem.swift
//  NameReminder
//
//  Created by Hadi Al zayer on 10/10/1446 AH.
//

import Foundation


import SwiftUI

struct PhotoItem: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var uiImage: UIImage

    var image: Image {
        Image(uiImage: uiImage)
    }
}

