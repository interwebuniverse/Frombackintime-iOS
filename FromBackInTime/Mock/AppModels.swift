//
//  AppModels.swift
//  FromBackInTime
//
//  UI-side domain models used across the main app. Ids are backend strings
//  (e.g. "rcp_..." / "msg_..."). DTO mapping initializers live at the bottom so
//  stores can turn repository responses straight into these.
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

    var needsMedia: Bool { self != .text }

    /// MIME type for the presigned R2 upload. Must be one the backend allows.
    var uploadContentType: String {
        switch self {
        case .video: return "video/mp4"
        case .voice: return "audio/m4a"
        case .photo: return "image/jpeg"
        case .text:  return ""
        }
    }
}

struct Recipient: Identifiable, Hashable {
    let id: String
    var name: String
    var relationship: String
    var email: String
    var initials: String
    /// Hue used to pick the avatar tint. Keeps colours stable across launches.
    var hue: Double

    init(id: String = "", name: String, relationship: String, email: String = "", hue: Double, initials: String? = nil) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.email = email
        self.initials = initials ?? Self.initials(from: name)
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
    let id: String
    var recipientID: String
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
    /// CTM only: whether the switch is armed on the backend.
    var ctmActivated: Bool

    init(
        id: String = "",
        recipientID: String,
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

    /// Human "Mom · Birthday · 2027-05-14" style title used in lists.
    func fileLabel(in recipients: [Recipient]) -> String {
        let name = recipients.first(where: { $0.id == recipientID })?.name ?? "Unknown"
        let date = deliveryDate.map { DateFormatter.fileDate.string(from: $0) } ?? "TBD"
        return "\(name) · \(occasion) · \(date)"
    }
}

// MARK: - DTO mapping

extension Recipient {
    init(dto: RecipientResponses.Recipient) {
        self.init(
            id: dto.id ?? "",
            name: dto.name ?? "",
            relationship: dto.relationship ?? "",
            email: dto.email ?? "",
            hue: dto.hue ?? 0.5,
            initials: dto.initials
        )
    }
}

extension Message {
    init(dto: MessageResponses.Message) {
        self.init(
            id: dto.id ?? "",
            recipientID: dto.recipientId ?? "",
            kind: MessageKind(rawValue: dto.kind ?? "standard") ?? .standard,
            medium: MessageMedium(rawValue: dto.medium ?? "text") ?? .text,
            occasion: dto.occasion ?? "",
            deliveryDate: APIDate.parse(dto.deliverAt),
            recordedAt: APIDate.parse(dto.createdAt) ?? .now,
            durationSeconds: dto.durationSeconds ?? 0,
            bodyText: dto.bodyText ?? "",
            // "armed" is the switch-set state; a released CTM moves to scheduled.
            ctmActivated: (dto.status == "armed" || dto.status == "scheduled")
        )
    }
}

// MARK: - Dates

/// ISO-8601 helpers for the backend contract (timestamps are ISO strings).
enum APIDate {
    private static let withFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    private static let plain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    static func parse(_ s: String?) -> Date? {
        guard let s, !s.isEmpty else { return nil }
        return withFraction.date(from: s) ?? plain.date(from: s)
    }

    static func string(_ date: Date) -> String {
        withFraction.string(from: date)
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
