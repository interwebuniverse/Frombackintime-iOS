//
//  AppModels.swift
//  FromBackInTime
//
//  UI-side domain models used across the main app. These are plain structs
//  (no DTOs yet) since the live backend isn't wired. When repositories land,
//  these are what stores will map to.
//

import SwiftUI

enum MessageKind: String, Codable, Hashable {
    case standard
    case ctm
}

enum MessageMedium: String, Codable, Hashable, CaseIterable, Identifiable {
    case video
    case voice
    case photo
    case text

    var id: String { rawValue }

    var title: String {
        switch self {
        case .video: return "Video message"
        case .voice: return "Voice note"
        case .photo: return "Photo & note"
        case .text: return "Written message"
        }
    }

    var shortLabel: String {
        switch self {
        case .video: return "Video"
        case .voice: return "Voice"
        case .photo: return "Photo"
        case .text: return "Text"
        }
    }

    var subtitle: String {
        switch self {
        case .video: return "See and hear you. Selfie camera, up to five minutes."
        case .voice: return "Just your voice. The intimate one, hands-free."
        case .photo: return "A single photo with a written message under it."
        case .text: return "Words alone. Evergreen, easy, anywhere."
        }
    }

    var icon: String {
        switch self {
        case .video: return "video.fill"
        case .voice: return "waveform"
        case .photo: return "photo.fill"
        case .text: return "text.alignleft"
        }
    }

    /// Hue used for the card gradient and small badge on lists.
    var hue: Double {
        switch self {
        case .video: return 0.58   // sky blue
        case .voice: return 0.78   // soft violet
        case .photo: return 0.07   // peach
        case .text:  return 0.36   // sage green
        }
    }
}

struct Recipient: Identifiable, Hashable {
    let id: UUID
    var name: String
    var relationship: String
    var initials: String
    /// Hue used to pick the avatar tint. Keeps colours stable across launches.
    var hue: Double

    init(id: UUID = UUID(), name: String, relationship: String, hue: Double) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.initials = Self.initials(from: name)
        self.hue = hue
    }

    var avatarColor: Color {
        Color(hue: hue, saturation: 0.55, brightness: 0.95)
    }

    static func initials(from name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first.map(String.init) }
        return letters.joined().uppercased()
    }
}

struct Message: Identifiable, Hashable {
    let id: UUID
    var recipientID: UUID
    var kind: MessageKind
    var medium: MessageMedium
    var occasion: String
    /// For standard messages: the scheduled delivery date.
    /// For CTM messages: nil until activated; once activated, the projected release date.
    var deliveryDate: Date?
    var recordedAt: Date
    /// For video/voice: recording length. For text: word count placeholder.
    var durationSeconds: Int
    /// For text/photo+note media: the body of the note. Empty for video/voice.
    var bodyText: String
    /// CTM only: whether the recipient has activated the dead-man's switch.
    var ctmActivated: Bool

    init(
        id: UUID = UUID(),
        recipientID: UUID,
        kind: MessageKind,
        medium: MessageMedium = .video,
        occasion: String,
        deliveryDate: Date?,
        recordedAt: Date = .now,
        durationSeconds: Int = 60,
        bodyText: String = "",
        ctmActivated: Bool = false
    ) {
        self.id = id
        self.recipientID = recipientID
        self.kind = kind
        self.medium = medium
        self.occasion = occasion
        self.deliveryDate = deliveryDate
        self.recordedAt = recordedAt
        self.durationSeconds = durationSeconds
        self.bodyText = bodyText
        self.ctmActivated = ctmActivated
    }

    /// Human "Mom_Birthday_2027-05-14" style title used in lists.
    func fileLabel(in recipients: [Recipient]) -> String {
        let name = recipients.first(where: { $0.id == recipientID })?.name ?? "Unknown"
        let date = deliveryDate.map { DateFormatter.fileDate.string(from: $0) } ?? "TBD"
        return "\(name) · \(occasion) · \(date)"
    }
}

extension DateFormatter {
    static let fileDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    static let prettyDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
}
