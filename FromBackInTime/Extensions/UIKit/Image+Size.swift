//
//  Image+Size.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

extension Image {
    func build(
        size: CGFloat,
        contentMode: ContentMode = .fit,
        foregroundColor: Color? = nil
    ) -> some View {
        self
            .renderingMode(foregroundColor == nil ? nil : .template)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .frame(width: size, height: size)
            .foregroundStyle(foregroundColor ?? Color(.label))
    }
}
