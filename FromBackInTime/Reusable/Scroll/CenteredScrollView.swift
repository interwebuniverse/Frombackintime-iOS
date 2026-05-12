//
//  CenteredScrollView.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

struct CenteredScrollView<Content: View> {
    @ViewBuilder let content: Content
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                content
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
            }
        }
    }
}
