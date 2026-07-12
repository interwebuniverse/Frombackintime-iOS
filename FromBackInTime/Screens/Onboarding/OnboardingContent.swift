//
//  OnboardingContent.swift
//  FromBackInTime
//
//  All onboarding copy and data in one place. Edit wording, questions,
//  features, and reviews here without touching the views.
//

import Foundation

// MARK: - Content models

struct OBEmpathyContent {
    let kicker: String
    let title: String
    let body: String
    var image: String = ""
}

/// One page of the feature showcase pager. The hero is a large color icon,
/// the satellites are two smaller icons orbiting it.
struct OBShowcasePage: Identifiable {
    let id: String
    let hero: String
    let satellites: [String]
    let title: String
    let subtitle: String
}

struct OBReview: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let quote: String
    let image: String
}

enum OnboardingContent {

    // MARK: - Quiz block one (who + why)

    static let blockOne: [OBQuestion] = [
        OBQuestion(
            id: "who",
            title: "Who is on your mind right now?",
            subtitle: "Pick whoever came to your heart first, even if it surprises you.",
            multiSelect: true,
            options: [
                OBOption(id: "love_here", emoji: "💛", text: "Someone I love who is still here"),
                OBOption(id: "lost", emoji: "🕊️", text: "Someone I've lost"),
                OBOption(id: "future_self", emoji: "🪞", text: "My future self"),
                OBOption(id: "child", emoji: "🧒", text: "My child, now or someday"),
                OBOption(id: "friend", emoji: "🤝", text: "A friend who needs to hear it"),
                OBOption(id: "unsure", emoji: "🤍", text: "I'm not sure yet")
            ]
        ),
        OBQuestion(
            id: "why",
            title: "What made you open this today?",
            subtitle: "There's no wrong answer.",
            multiSelect: false,
            options: [
                OBOption(id: "unsaid", emoji: "💬", text: "Something has been left unsaid",
                         reveal: "Most of us carry words we never say out loud. You're choosing not to."),
                OBOption(id: "legacy", emoji: "🌱", text: "I want to leave something behind",
                         reveal: "Legacy isn't a document. It's your voice, your laugh, the things only you can give."),
                OBOption(id: "cant_reach", emoji: "📡", text: "I'm thinking of someone I can't reach",
                         reveal: "Distance doesn't have to be silent. Time can carry your words for you."),
                OBOption(id: "drawn", emoji: "✨", text: "I'm not sure, but something brought me here",
                         reveal: "That's enough. We'll find it together.")
            ]
        )
    ]

    // MARK: - Quiz block two (fear + urgency)

    static let blockTwo: [OBQuestion] = [
        OBQuestion(
            id: "hardest",
            title: "What's the hardest part of saying these things now?",
            subtitle: "Pick everything that feels true.",
            multiSelect: true,
            options: [
                OBOption(id: "freeze", emoji: "🧊", text: "I freeze when I try to say it out loud"),
                OBOption(id: "too_soon", emoji: "⏳", text: "It feels too soon"),
                OBOption(id: "too_late", emoji: "🌙", text: "It feels too late"),
                OBOption(id: "not_while_here", emoji: "🤐", text: "I don't want them to hear it while I'm here"),
                OBOption(id: "not_ready", emoji: "🫧", text: "They wouldn't be ready for it yet"),
                OBOption(id: "dont_know", emoji: "❓", text: "I don't know how to start")
            ]
        ),
        OBQuestion(
            id: "if_tomorrow",
            title: "If something happened to you tomorrow, who would need to hear from you?",
            subtitle: "This is the heart of why we built this.",
            multiSelect: true,
            options: [
                OBOption(id: "children", emoji: "👶", text: "My children"),
                OBOption(id: "partner", emoji: "💞", text: "My partner"),
                OBOption(id: "parents", emoji: "🧓", text: "My parents"),
                OBOption(id: "close_friends", emoji: "🫂", text: "My closest friends"),
                OBOption(id: "everyone", emoji: "🌍", text: "Everyone I love"),
                OBOption(id: "rather_not", emoji: "🤍", text: "I'd rather not think about it yet")
            ]
        )
    ]

    // MARK: - Empathy interstitial

    static let empathyOne = OBEmpathyContent(
        kicker: "You're not alone in this",
        title: "Almost everyone has someone they think of first.",
        body: "The fact that a face came to mind so quickly means the words are already there. They just need somewhere safe to go.",
        image: "ob-sky-empathy1"
    )

    // MARK: - Feature showcase pages

    static let showcasePages: [OBShowcasePage] = [
        OBShowcasePage(
            id: "record",
            hero: "ob-d-microphone",
            satellites: ["ob-d-video", "ob-d-photo"],
            title: "Say it the way only you can.",
            subtitle: "Voice, video, or a photo with a few words. Whatever feels honest."
        ),
        OBShowcasePage(
            id: "schedule",
            hero: "ob-d-calendar",
            satellites: ["ob-d-gift", "ob-d-clock"],
            title: "Pick the moment it arrives.",
            subtitle: "Tomorrow, their 18th birthday, or ten years from now. You choose the day."
        ),
        OBShowcasePage(
            id: "secure",
            hero: "ob-d-lock",
            satellites: ["ob-d-shield", "ob-d-heart"],
            title: "Sealed the moment you finish.",
            subtitle: "Encrypted end to end. Only the person you choose will ever see it."
        ),
        OBShowcasePage(
            id: "deliver",
            hero: "ob-d-plane",
            satellites: ["ob-d-envelope", "ob-d-bell"],
            title: "It arrives gently, on your day.",
            subtitle: "By email or in the app. Add a backup recipient for peace of mind."
        )
    ]

    // MARK: - Social proof

    static let averageRating = 4.8
    static let ratingCount = 12480
    static let messagesDelivered = 318000

    static let reviews: [OBReview] = [
        OBReview(name: "Sarah", age: 34,
                 quote: "I recorded a message for my daughter's wedding day. She's four right now. I cried making it, and I'll cry less knowing she'll have it.",
                 image: "review-sarah"),
        OBReview(name: "Michael", age: 47,
                 quote: "I lost my dad before we said the things we should have. This means my kids will never have to feel that.",
                 image: "review-michael"),
        OBReview(name: "Elena", age: 58,
                 quote: "After my diagnosis I needed a way to be there for birthdays I might miss. Now I am.",
                 image: "review-elena")
    ]

    // MARK: - Preferences

    static let preferenceOptions: [OBOption] = [
        OBOption(id: "reminders", emoji: "🔔", text: "Send me gentle reminders to record"),
        OBOption(id: "never_share", emoji: "🔒", text: "Never share my data, ever"),
        OBOption(id: "backup", emoji: "🧷", text: "Let me name a backup recipient"),
        OBOption(id: "encrypt", emoji: "🛡️", text: "Encrypt everything by default"),
        OBOption(id: "allow_ctm", emoji: "🕰️", text: "Allow Critical Timed Messages"),
        OBOption(id: "simple", emoji: "🤍", text: "Keep it simple for now")
    ]
}
