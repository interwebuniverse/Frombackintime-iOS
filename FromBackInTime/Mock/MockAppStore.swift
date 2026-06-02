//
//  MockAppStore.swift
//  FromBackInTime
//
//  Shared in-memory store for the demo. Every screen reads from and writes
//  to this. Seeded with believable starter data so the app feels populated
//  from first launch. When the real backend lands, this is replaced by
//  feature-specific Stores backed by Repositories.
//

import SwiftUI

@MainActor
@Observable
final class MockAppStore {
    var recipients: [Recipient]
    var messages: [Message]

    init(seed: Bool = true) {
        if seed {
            let seeded = Self.seedData()
            self.recipients = seeded.recipients
            self.messages = seeded.messages
        } else {
            self.recipients = []
            self.messages = []
        }
    }

    // MARK: - Recipients

    func addRecipient(name: String, relationship: String) {
        let used: Set<Int> = Set(recipients.map { Int($0.hue * 360) })
        var hue: Double = Double.random(in: 0...1)
        for step in 0..<36 {
            let candidate = Double(step) * 10.0 / 360.0
            if !used.contains(Int(candidate * 360)) { hue = candidate; break }
        }
        recipients.append(Recipient(name: name, relationship: relationship, hue: hue))
    }

    func recipient(id: UUID) -> Recipient? {
        recipients.first(where: { $0.id == id })
    }

    // MARK: - Messages

    func standardMessages(for recipientID: UUID? = nil) -> [Message] {
        messages
            .filter { $0.kind == .standard && (recipientID == nil || $0.recipientID == recipientID) }
            .sorted { ($0.deliveryDate ?? .distantFuture) < ($1.deliveryDate ?? .distantFuture) }
    }

    func ctmMessages(for recipientID: UUID? = nil) -> [Message] {
        messages
            .filter { $0.kind == .ctm && (recipientID == nil || $0.recipientID == recipientID) }
            .sorted { $0.recordedAt > $1.recordedAt }
    }

    func upcoming(within days: Int = 365, limit: Int = 5) -> [Message] {
        let cutoff = Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .distantFuture
        return messages
            .filter { $0.kind == .standard }
            .compactMap { msg -> (Message, Date)? in
                guard let d = msg.deliveryDate, d >= .now, d <= cutoff else { return nil }
                return (msg, d)
            }
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map { $0.0 }
    }

    func saveMessage(_ message: Message) {
        if let idx = messages.firstIndex(where: { $0.id == message.id }) {
            messages[idx] = message
        } else {
            messages.append(message)
        }
    }

    func deleteMessage(id: UUID) {
        messages.removeAll(where: { $0.id == id })
    }

    /// Wipes everything and re-seeds. Used by Settings -> Delete account so
    /// the next onboarding run lands on a fresh, populated app.
    func resetToSeed() {
        let seeded = Self.seedData()
        recipients = seeded.recipients
        messages = seeded.messages
    }

    func toggleCTMActivation(id: UUID) {
        guard let idx = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[idx].ctmActivated.toggle()
        if messages[idx].ctmActivated, messages[idx].deliveryDate == nil {
            // Projected release: 30 days from activation per spec.
            messages[idx].deliveryDate = Calendar.current.date(byAdding: .day, value: 30, to: .now)
        }
    }

    // MARK: - Seed

    private static func seedData() -> (recipients: [Recipient], messages: [Message]) {
        let mom = Recipient(name: "Mom", relationship: "Mother", hue: 0.95)
        let dad = Recipient(name: "Dad", relationship: "Father", hue: 0.58)
        let son = Recipient(name: "Liam", relationship: "Son", hue: 0.30)
        let daughter = Recipient(name: "Ava", relationship: "Daughter", hue: 0.83)
        let charlie = Recipient(name: "Charlie", relationship: "Brother", hue: 0.07)
        let sara = Recipient(name: "Sara", relationship: "Best friend", hue: 0.45)

        let cal = Calendar.current
        let now = Date.now
        func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
            cal.date(from: DateComponents(year: y, month: m, day: d)) ?? now
        }
        func daysAgo(_ d: Int) -> Date { cal.date(byAdding: .day, value: -d, to: now) ?? now }

        let messages: [Message] = [
            .init(recipientID: mom.id, kind: .standard, medium: .video, occasion: "Birthday",
                  deliveryDate: date(2027, 5, 14), recordedAt: daysAgo(12), durationSeconds: 92),
            .init(recipientID: dad.id, kind: .standard, medium: .voice, occasion: "Birthday",
                  deliveryDate: date(2026, 12, 7), recordedAt: daysAgo(40), durationSeconds: 74),
            .init(recipientID: son.id, kind: .standard, medium: .video, occasion: "Graduation",
                  deliveryDate: date(2028, 5, 7), recordedAt: daysAgo(3), durationSeconds: 121),
            .init(recipientID: daughter.id, kind: .standard, medium: .photo, occasion: "Wedding day",
                  deliveryDate: date(2031, 6, 22), recordedAt: daysAgo(80), durationSeconds: 0,
                  bodyText: "A photo from the day you were born. I will love you long after I am gone."),
            .init(recipientID: charlie.id, kind: .standard, medium: .text, occasion: "30th birthday",
                  deliveryDate: date(2027, 1, 19), recordedAt: daysAgo(20), durationSeconds: 0,
                  bodyText: "Brother, you made it to thirty. Whatever this year holds, remember who you are. Steady. Kind. Stubborn in the right ways. I am proud of you."),
            .init(recipientID: sara.id, kind: .standard, medium: .voice, occasion: "Words of encouragement",
                  deliveryDate: date(2026, 9, 9), recordedAt: daysAgo(7), durationSeconds: 47),
            // CTMs
            .init(recipientID: mom.id, kind: .ctm, medium: .text, occasion: "Passwords & accounts",
                  deliveryDate: nil, recordedAt: daysAgo(55), durationSeconds: 0,
                  bodyText: "Bank: …\nApple ID: …\nSafe deposit code: …", ctmActivated: false),
            .init(recipientID: dad.id, kind: .ctm, medium: .video, occasion: "Last words",
                  deliveryDate: nil, recordedAt: daysAgo(90), durationSeconds: 240, ctmActivated: false),
            .init(recipientID: son.id, kind: .ctm, medium: .voice, occasion: "Things I want you to know",
                  deliveryDate: nil, recordedAt: daysAgo(15), durationSeconds: 150, ctmActivated: false),
        ]
        return ([mom, dad, son, daughter, charlie, sara], messages)
    }
}
