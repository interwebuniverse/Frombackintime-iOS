//
//  RecipientAvatar.swift
//  FromBackInTime
//
//  Coloured circle + initials used everywhere a person appears. Stable per
//  recipient since the hue is part of the model.
//

import SwiftUI

struct RecipientAvatar: View {
    let recipient: Recipient
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            Circle()
                .fill(recipient.avatarColor.opacity(0.22))
            Circle()
                .strokeBorder(recipient.avatarColor.opacity(0.55), lineWidth: 1.5)
            Text(recipient.initials)
                .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
        }
        .frame(width: size, height: size)
    }
}
