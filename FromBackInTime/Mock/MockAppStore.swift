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
    /// True once the first load attempt has finished (success or failure), so
    /// screens can tell "still loading for the first time" from "loaded, empty".
    var hasLoaded = false
    var error: String?

    /// The very first load, before any data has arrived: show a spinner, not an
    /// empty state that would wrongly read as "you have nothing".
    var isInitialLoading: Bool { isLoading && !hasLoaded }

    /// Cold-launch lifecycle for the branded launch screen: the app stays on
    /// LaunchView until the first full load lands (or fails, with a retry).
    enum BootstrapPhase: Equatable {
        case idle, loading, ready
        case failed(String)
    }
    var bootstrapPhase: BootstrapPhase = .idle
    /// Whether the most recent load() ended in a thrown error. Session errors
    /// don't surface in `error`, so this is the reliable failure signal.
    @ObservationIgnored private var lastLoadFailed = false
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
        guard !isMock else {
            bootstrapPhase = .ready
            return
        }
        bootstrapPhase = .loading
        await load()
        if lastLoadFailed {
            bootstrapPhase = .failed(error ?? "We couldn't reach your vault. Check your connection and try again.")
        } else {
            bootstrapPhase = .ready
        }
    }

    func load() async {
        guard !isMock else { return }
        isLoading = true
        error = nil
        defer { isLoading = false; hasLoaded = true }
        do {
            async let recips = recipientRepository.list()
            async let msgs = messageRepository.list(kind: nil)
            let (r, m) = try await (recips, msgs)
            recipients = r.map(Recipient.init(dto:))
            messages = m.map(Message.init(dto:))
            lastLoadFailed = false
        } catch {
            lastLoadFailed = true
            setError(error)
        }
    }

    // MARK: - Recipients

    @discardableResult
    func addRecipient(name: String, relationship: String, email: String = "") async -> Bool {
        if isMock {
            recipients.append(Recipient(name: name, relationship: relationship, email: email, hue: nextHue()))
            return true
        }
        do {
            let dto = try await recipientRepository.create(
                name: name,
                relationship: relationship.isEmpty ? nil : relationship,
                email: email,
                hue: nextHue()
            )
            recipients.insert(Recipient(dto: dto), at: 0)
            return true
        } catch {
            setError(error)
            return false
        }
    }

    @discardableResult
    func updateRecipient(id: String, name: String, relationship: String, email: String) async -> Bool {
        guard let idx = recipients.firstIndex(where: { $0.id == id }) else { return false }
        if isMock {
            recipients[idx].name = name
            recipients[idx].relationship = relationship
            recipients[idx].email = email
            return true
        }
        do {
            let dto = try await recipientRepository.update(
                id: id,
                name: name,
                relationship: relationship.isEmpty ? nil : relationship,
                email: email,
                hue: nil
            )
            recipients[idx] = Recipient(dto: dto)
            return true
        } catch {
            setError(error)
            return false
        }
    }

    /// Delete a recipient. The backend refuses (409) while they still have
    /// armed or scheduled messages, which comes back as `error`.
    @discardableResult
    func deleteRecipient(id: String) async -> Bool {
        if !isMock {
            do { try await recipientRepository.delete(id: id) }
            catch { setError(error); return false }
        }
        recipients.removeAll(where: { $0.id == id })
        // Drop the recipient's messages too so the mock lists don't keep showing
        // now-orphaned rows as "Unknown" (the live path is guarded server-side).
        messages.removeAll(where: { $0.recipientID == id })
        return true
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
    @discardableResult
    func saveMessage(_ message: Message, mediaData: Data? = nil, mediaContentType: String? = nil) async -> Bool {
        if isMock {
            if let idx = messages.firstIndex(where: { $0.id == message.id }) {
                messages[idx] = message
            } else {
                messages.insert(message, at: 0)
            }
            return true
        }
        // A video/voice/photo message with no bytes must never be created: it
        // would finalize into a message that can never deliver. Fail loudly so
        // the composer surfaces it instead of faking a successful save.
        if message.medium.needsMedia, (mediaData?.isEmpty ?? true) {
            error = "That message has no media to send. Please record it again."
            return false
        }
        do {
            let created = try await messageRepository.create(
                recipientId: message.recipientID,
                kind: message.kind.rawValue,
                medium: message.medium.rawValue,
                occasion: message.occasion.isEmpty ? nil : message.occasion,
                bodyText: message.bodyText.isEmpty ? nil : message.bodyText,
                durationSeconds: message.durationSeconds,
                deliverAt: message.deliveryDate.map { APIDate.string(Self.effectiveDelivery($0)) }
            )
            guard let id = created.id else { throw NetworkError.badResponse }

            do {
                var finalDto = created
                if message.medium.needsMedia, let data = mediaData {
                    let contentType = mediaContentType ?? message.medium.uploadContentType
                    let upload = try await messageRepository.requestUploadURL(id: id, contentType: contentType)
                    guard let url = upload.uploadUrl else { throw NetworkError.badResponse }
                    try await messageRepository.uploadMedia(to: url, data: data, contentType: contentType)
                    finalDto = try await messageRepository.finalize(id: id)
                } else if !message.medium.needsMedia, message.kind == .standard {
                    finalDto = try await messageRepository.finalize(id: id)
                }
                // needsMedia without bytes: the draft stays (composer prevents
                // this in practice; CTMs finalize/arm later).
                messages.insert(Message(dto: finalDto), at: 0)
                return true
            } catch {
                // Roll the draft back so a failed save never leaves a ghost
                // message that would silently never deliver.
                try? await messageRepository.delete(id: id)
                throw error
            }
        } catch {
            setError(error)
            return false
        }
    }

    /// The user picks a delivery moment before recording, so by the time save
    /// runs it can already be seconds in the past and the backend would reject
    /// it. A pick that slipped behind the clock means "as soon as possible":
    /// send it one minute out instead of failing the save.
    static func effectiveDelivery(_ date: Date) -> Date {
        max(date, .now.addingTimeInterval(60))
    }

    /// Edit a scheduled message's occasion, recipient, or delivery date. The
    /// media itself can't change; to replace it the user re-records.
    @discardableResult
    func updateMessage(id: String, occasion: String, recipientId: String, deliveryDate: Date?) async -> Bool {
        guard let idx = messages.firstIndex(where: { $0.id == id }) else { return false }
        if isMock {
            messages[idx].occasion = occasion
            messages[idx].recipientID = recipientId
            messages[idx].deliveryDate = deliveryDate
            return true
        }
        do {
            let dto = try await messageRepository.patch(
                id: id,
                occasion: occasion.isEmpty ? nil : occasion,
                recipientId: recipientId,
                deliverAt: deliveryDate.map { APIDate.string(Self.effectiveDelivery($0)) }
            )
            messages[idx] = Message(dto: dto)
            return true
        } catch {
            setError(error)
            return false
        }
    }

    /// Fetch the full message: decrypted body text plus a short-lived playback
    /// URL for its media. Also refreshes the row in the loaded list.
    func messageDetail(id: String) async -> (message: Message, mediaURL: URL?)? {
        if isMock {
            guard let msg = messages.first(where: { $0.id == id }) else { return nil }
            return (msg, nil)
        }
        do {
            let dto = try await messageRepository.detail(id: id)
            let msg = Message(dto: dto)
            if let idx = messages.firstIndex(where: { $0.id == id }) {
                messages[idx] = msg
            }
            let url = dto.media?.url.flatMap(URL.init(string:))
            return (msg, url)
        } catch {
            setError(error)
            return nil
        }
    }

    @discardableResult
    func deleteMessage(id: String) async -> Bool {
        if !isMock {
            do { try await messageRepository.delete(id: id) }
            catch { setError(error); return false }
        }
        messages.removeAll(where: { $0.id == id })
        return true
    }

    /// Arm a CTM switch. The backend has no "un-arm", so toggling an already
    /// armed switch off is a no-op there (delete the message to cancel it).
    @discardableResult
    func toggleCTMActivation(id: String) async -> Bool {
        guard let idx = messages.firstIndex(where: { $0.id == id }) else { return false }
        if isMock {
            messages[idx].ctmActivated.toggle()
            if messages[idx].ctmActivated, messages[idx].deliveryDate == nil {
                messages[idx].deliveryDate = Calendar.current.date(byAdding: .day, value: 30, to: .now)
            }
            return true
        }
        guard !messages[idx].ctmActivated else { return true }
        do {
            let activation = try await ctmRepository.activate(messageId: id, checkinIntervalDays: nil, releaseThreshold: nil)
            messages[idx].ctmActivated = true
            messages[idx].deliveryDate = APIDate.parse(activation.nextCheckinAt)
            lastAccessCode = activation.accessCode
            return true
        } catch {
            setError(error)
            return false
        }
    }

    // MARK: - CTM check-ins (the "I'm alive" controls)

    /// True when any armed switch exists, i.e. the user has check-ins to keep.
    var hasArmedCTM: Bool {
        messages.contains { $0.kind == .ctm && $0.ctmActivated }
    }

    /// The soonest projected release across armed switches.
    var nextCTMDate: Date? {
        messages
            .filter { $0.kind == .ctm && $0.ctmActivated }
            .compactMap(\.deliveryDate)
            .min()
    }

    @discardableResult
    func checkIn() async -> Bool {
        if isMock {
            bumpMockCTMDates(byDays: 30)
            return true
        }
        do { _ = try await ctmRepository.checkIn(); await load(); return true }
        catch { setError(error); return false }
    }

    @discardableResult
    func snooze() async -> Bool {
        if isMock {
            bumpMockCTMDates(byDays: 7)
            return true
        }
        do { _ = try await ctmRepository.snooze(); await load(); return true }
        catch { setError(error); return false }
    }

    private func bumpMockCTMDates(byDays days: Int) {
        for idx in messages.indices where messages[idx].kind == .ctm && messages[idx].ctmActivated {
            messages[idx].deliveryDate = Calendar.current.date(byAdding: .day, value: days, to: .now)
        }
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
