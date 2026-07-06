//
//  MockAppStore.swift
//  FromBackInTime
//
//  The single app-wide store every product screen reads and writes. It now sits
//  on top of the real repositories: in the live environment reads/writes hit the
//  backend, in the Mock scheme it stays fully in-memory with seeded data (no
//  network). The public method surface is unchanged so the screens didn't move.
//

import SwiftUI

@MainActor
@Observable
final class MockAppStore {
    var recipients: [Recipient] = []
    var messages: [Message] = []
    var isLoading = false
    var error: String?
    /// The access code returned once when a CTM is armed. The owner shares it
    /// with the recipient out of band; surfaced once, never retrievable again.
    var lastAccessCode: String?

    @ObservationIgnored private let recipientRepository: RecipientRepositoryType
    @ObservationIgnored private let messageRepository: MessageRepositoryType
    @ObservationIgnored private let ctmRepository: CTMRepositoryType
    @ObservationIgnored private let environment: AppEnvironment

    private var isMock: Bool { environment.isMock }

    init(
        recipientRepository: RecipientRepositoryType,
        messageRepository: MessageRepositoryType,
        ctmRepository: CTMRepositoryType,
        environment: AppEnvironment = .current
    ) {
        self.recipientRepository = recipientRepository
        self.messageRepository = messageRepository
        self.ctmRepository = ctmRepository
        self.environment = environment
        if isMock {
            let seeded = Self.seedData()
            recipients = seeded.recipients
            messages = seeded.messages
        }
    }

    /// Convenience for previews / the Mock scheme: builds mock-backed repos.
    convenience init(environment: AppEnvironment = .mock) {
        let client = NetworkClientFactory.make(environment: environment)
        self.init(
            recipientRepository: RecipientRepository(client: client),
            messageRepository: MessageRepository(client: client),
            ctmRepository: CTMRepository(client: client),
            environment: environment
        )
    }

    // MARK: - Loading

    /// Load everything from the backend. No-op in mock (seed already in place).
    func bootstrap() async {
        guard !isMock else { return }
        await load()
    }

    func load() async {
        guard !isMock else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            async let recips = recipientRepository.list()
            async let msgs = messageRepository.list(kind: nil)
            let (r, m) = try await (recips, msgs)
            recipients = r.map(Recipient.init(dto:))
            messages = m.map(Message.init(dto:))
        } catch {
            setError(error)
        }
    }

    // MARK: - Recipients

    func addRecipient(name: String, relationship: String, email: String = "") async {
        if isMock {
            recipients.append(Recipient(name: name, relationship: relationship, email: email, hue: nextHue()))
            return
        }
        do {
            let dto = try await recipientRepository.create(
                name: name,
                relationship: relationship.isEmpty ? nil : relationship,
                email: email,
                hue: nextHue()
            )
            recipients.insert(Recipient(dto: dto), at: 0)
        } catch {
            setError(error)
        }
    }

    func recipient(id: String) -> Recipient? {
        recipients.first(where: { $0.id == id })
    }

    // MARK: - Messages (reads filter the loaded arrays)

    func standardMessages(for recipientID: String? = nil) -> [Message] {
        messages
            .filter { $0.kind == .standard && (recipientID == nil || $0.recipientID == recipientID) }
            .sorted { ($0.deliveryDate ?? .distantFuture) < ($1.deliveryDate ?? .distantFuture) }
    }

    func ctmMessages(for recipientID: String? = nil) -> [Message] {
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

    /// Create a message on the backend. `mediaData` carries the recorded blob for
    /// video/voice/photo; when present it is uploaded to R2 and the message is
    /// finalized. Text standard messages finalize immediately (which schedules
    /// them). CTM messages stay draft until armed via `toggleCTMActivation`.
    func saveMessage(_ message: Message, mediaData: Data? = nil) async {
        if isMock {
            if let idx = messages.firstIndex(where: { $0.id == message.id }) {
                messages[idx] = message
            } else {
                messages.insert(message, at: 0)
            }
            return
        }
        do {
            let created = try await messageRepository.create(
                recipientId: message.recipientID,
                kind: message.kind.rawValue,
                medium: message.medium.rawValue,
                occasion: message.occasion.isEmpty ? nil : message.occasion,
                bodyText: message.bodyText.isEmpty ? nil : message.bodyText,
                durationSeconds: message.durationSeconds,
                deliverAt: message.deliveryDate.map(APIDate.string)
            )
            guard let id = created.id else { return }

            var finalDto = created
            if message.medium.needsMedia {
                if let data = mediaData {
                    let upload = try await messageRepository.requestUploadURL(id: id, contentType: message.medium.uploadContentType)
                    if let url = upload.uploadUrl {
                        try await messageRepository.uploadMedia(to: url, data: data, contentType: message.medium.uploadContentType)
                        finalDto = try await messageRepository.finalize(id: id)
                    }
                }
                // No bytes captured yet: the draft still appears in lists.
            } else if message.kind == .standard {
                finalDto = try await messageRepository.finalize(id: id)
            }
            messages.insert(Message(dto: finalDto), at: 0)
        } catch {
            setError(error)
        }
    }

    func deleteMessage(id: String) async {
        if !isMock {
            do { try await messageRepository.delete(id: id) }
            catch { setError(error); return }
        }
        messages.removeAll(where: { $0.id == id })
    }

    /// Arm a CTM switch. The backend has no "un-arm", so toggling an already
    /// armed switch off is a no-op there (delete the message to cancel it).
    func toggleCTMActivation(id: String) async {
        guard let idx = messages.firstIndex(where: { $0.id == id }) else { return }
        if isMock {
            messages[idx].ctmActivated.toggle()
            if messages[idx].ctmActivated, messages[idx].deliveryDate == nil {
                messages[idx].deliveryDate = Calendar.current.date(byAdding: .day, value: 30, to: .now)
            }
            return
        }
        guard !messages[idx].ctmActivated else { return }
        do {
            let activation = try await ctmRepository.activate(messageId: id, checkinIntervalDays: nil, releaseThreshold: nil)
            messages[idx].ctmActivated = true
            messages[idx].deliveryDate = APIDate.parse(activation.nextCheckinAt)
            lastAccessCode = activation.accessCode
        } catch {
            setError(error)
        }
    }

    // MARK: - CTM check-ins (the "I'm alive" controls)

    func checkIn() async {
        guard !isMock else { return }
        do { _ = try await ctmRepository.checkIn() }
        catch { setError(error) }
    }

    func snooze() async {
        guard !isMock else { return }
        do { _ = try await ctmRepository.snooze() }
        catch { setError(error) }
    }

    /// Reload from the backend. In mock, re-seed (used by Settings -> Delete).
    func resetToSeed() {
        if isMock {
            let seeded = Self.seedData()
            recipients = seeded.recipients
            messages = seeded.messages
        } else {
            recipients = []
            messages = []
        }
    }

    // MARK: - Helpers

    private func setError(_ error: Error) {
        if !error.isSessionEnded {
            self.error = error.localizedDescription
        }
    }

    private func nextHue() -> Double {
        let used: Set<Int> = Set(recipients.map { Int($0.hue * 360) })
        for step in 0..<36 {
            let candidate = Double(step) * 10.0 / 360.0
            if !used.contains(Int(candidate * 360)) { return candidate }
        }
        return Double.random(in: 0...1)
    }

    // MARK: - Seed (mock scheme only)

    private static func seedData() -> (recipients: [Recipient], messages: [Message]) {
        let mom = Recipient(id: "seed-mom", name: "Mom", relationship: "Mother", email: "mom@example.com", hue: 0.95)
        let dad = Recipient(id: "seed-dad", name: "Dad", relationship: "Father", email: "dad@example.com", hue: 0.58)
        let son = Recipient(id: "seed-liam", name: "Liam", relationship: "Son", email: "liam@example.com", hue: 0.30)
        let daughter = Recipient(id: "seed-ava", name: "Ava", relationship: "Daughter", email: "ava@example.com", hue: 0.83)
        let charlie = Recipient(id: "seed-charlie", name: "Charlie", relationship: "Brother", email: "charlie@example.com", hue: 0.07)
        let sara = Recipient(id: "seed-sara", name: "Sara", relationship: "Best friend", email: "sara@example.com", hue: 0.45)

        let cal = Calendar.current
        let now = Date.now
        func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
            cal.date(from: DateComponents(year: y, month: m, day: d)) ?? now
        }
        func daysAgo(_ d: Int) -> Date { cal.date(byAdding: .day, value: -d, to: now) ?? now }

        var seq = 0
        func mid() -> String { seq += 1; return "seed-msg-\(seq)" }

        let messages: [Message] = [
            .init(id: mid(), recipientID: mom.id, kind: .standard, medium: .video, occasion: "Birthday",
                  deliveryDate: date(2027, 5, 14), recordedAt: daysAgo(12), durationSeconds: 92),
            .init(id: mid(), recipientID: dad.id, kind: .standard, medium: .voice, occasion: "Birthday",
                  deliveryDate: date(2026, 12, 7), recordedAt: daysAgo(40), durationSeconds: 74),
            .init(id: mid(), recipientID: son.id, kind: .standard, medium: .video, occasion: "Graduation",
                  deliveryDate: date(2028, 5, 7), recordedAt: daysAgo(3), durationSeconds: 121),
            .init(id: mid(), recipientID: daughter.id, kind: .standard, medium: .photo, occasion: "Wedding day",
                  deliveryDate: date(2031, 6, 22), recordedAt: daysAgo(80), durationSeconds: 0,
                  bodyText: "A photo from the day you were born. I will love you long after I am gone."),
            .init(id: mid(), recipientID: charlie.id, kind: .standard, medium: .text, occasion: "30th birthday",
                  deliveryDate: date(2027, 1, 19), recordedAt: daysAgo(20), durationSeconds: 0,
                  bodyText: "Brother, you made it to thirty. Whatever this year holds, remember who you are."),
            .init(id: mid(), recipientID: sara.id, kind: .standard, medium: .voice, occasion: "Words of encouragement",
                  deliveryDate: date(2026, 9, 9), recordedAt: daysAgo(7), durationSeconds: 47),
            // CTMs
            .init(id: mid(), recipientID: mom.id, kind: .ctm, medium: .text, occasion: "Passwords & accounts",
                  deliveryDate: nil, recordedAt: daysAgo(55), durationSeconds: 0,
                  bodyText: "Bank: ...\nApple ID: ...\nSafe deposit code: ...", ctmActivated: false),
            .init(id: mid(), recipientID: dad.id, kind: .ctm, medium: .video, occasion: "Last words",
                  deliveryDate: nil, recordedAt: daysAgo(90), durationSeconds: 240, ctmActivated: false),
            .init(id: mid(), recipientID: son.id, kind: .ctm, medium: .voice, occasion: "Things I want you to know",
                  deliveryDate: nil, recordedAt: daysAgo(15), durationSeconds: 150, ctmActivated: false),
        ]
        return ([mom, dad, son, daughter, charlie, sara], messages)
    }
}
