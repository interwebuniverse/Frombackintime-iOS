//
//  UIImage+MultipartFile.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import UIKit

extension UIImage {
    func multipartFile(name: String = "images", compressionQuality: CGFloat = 1) -> MultipartFile? {
        guard
            let data = self.jpegData(compressionQuality: compressionQuality)
        else {
            return nil
        }
        
        return .init(
            fieldName: "images",
            fileName: UUID().uuidString + ".jpg",
            mimeType: "image/jpeg",
            fileData: data
        )
    }
}
