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
    let imageDescription: String
    var image: String = ""
}

struct OBChip: Hashable {
    let icon: String
    let label: String
    var illustration: String = ""   // optional 3D illustration asset
}

struct OBFeatureContent {
    let title: String
    let subtitle: String
    let imageDescription: String
    let chips: [OBChip]
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

    // MARK: - Empathy interstitials

    static let empathyOne = OBEmpathyContent(
        kicker: "You're not alone in this",
        title: "Almost everyone has someone they think of first.",
        body: "The fact that a face came to mind so quickly means the words are already there. They just need somewhere safe to go.",
        imageDescription: "Warm, quiet illustration: a single hand holding a small glowing light, soft and reassuring",
        image: "ob-sky-empathy1"
    )

    static let empathyTwo = OBEmpathyContent(
        kicker: "We hear you",
        title: "The hardest words are the ones that matter most.",
        body: "You don't have to find the perfect way to say it today. You only have to say it once. We'll keep it safe until the right moment.",
        imageDescription: "Soft illustration: an open envelope with gentle light coming out, calm and hopeful",
        image: "ob-sky-empathy2"
    )

    // MARK: - Features

    static let featureRecord = OBFeatureContent(
        title: "Speak it the way only you can.",
        subtitle: "Voice, video, or a photo and a few words. Whatever feels honest.",
        imageDescription: "App mockup: record screen with a large record button and a 00:12 timer",
        chips: [OBChip(icon: "ob-microphone", label: "Voice", illustration: "ob-item-voice"),
                OBChip(icon: "ob-video", label: "Video", illustration: "ob-item-video"),
                OBChip(icon: "ob-image", label: "Photo + note", illustration: "ob-item-photo")]
    )

    static let featureSchedule = OBFeatureContent(
        title: "Pick the moment it should arrive.",
        subtitle: "Tomorrow, a decade from now, or a birthday you won't be there for.",
        imageDescription: "App mockup: calendar with one date glowing, date-picker chips below",
        chips: [OBChip(icon: "ob-calendar", label: "Next month", illustration: "ob-item-month"),
                OBChip(icon: "ob-calendar", label: "On their 18th", illustration: "ob-item-18th"),
                OBChip(icon: "ob-clock", label: "5 years", illustration: "ob-item-5y"),
                OBChip(icon: "ob-calendar", label: "Custom date", illustration: "ob-item-custom")]
    )

    static let featureSecure = OBFeatureContent(
        title: "Locked the moment you finish.",
        subtitle: "Everything is encrypted end to end. Even we can't watch it.",
        imageDescription: "App mockup: a lock animating closed over a video thumbnail",
        chips: [OBChip(icon: "ob-lock", label: "End-to-end encrypted", illustration: "ob-item-encrypted"),
                OBChip(icon: "ob-shield", label: "Private by default", illustration: "ob-item-private")]
    )

    static let featureDeliver = OBFeatureContent(
        title: "It arrives gently, on the day you chose.",
        subtitle: "By email, in the app, or both. Whichever way they're easier to reach.",
        imageDescription: "App mockup: an arriving message with a soft glow and a delivery confirmation",
        chips: [OBChip(icon: "ob-envelope", label: "Email", illustration: "ob-item-email"),
                OBChip(icon: "ob-device", label: "In-app", illustration: "ob-item-inapp"),
                OBChip(icon: "ob-bell", label: "Both", illustration: "ob-item-both")]
    )

    static let featureCTM = OBFeatureContent(
        title: "If you ever can't deliver it yourself, we will.",
        subtitle: "We send gentle check-ins on your schedule. Confirm with one tap. Miss too many, and your trusted person hears from you anyway.",
        imageDescription: "App mockup: Critical Timed Message check-in card with 'I'm here', 'Snooze', 'Plan ahead'",
        chips: [OBChip(icon: "ob-calendar", label: "Gentle check-ins", illustration: "ob-item-checkin"),
                OBChip(icon: "ob-seal-check", label: "One-tap confirm", illustration: "ob-item-confirm"),
                OBChip(icon: "ob-hand-heart", label: "Optional", illustration: "ob-item-optional")]
    )

    static let featureRecipients = OBFeatureContent(
        title: "One trusted person. Or many.",
        subtitle: "You decide who hears what, and when. Add a backup recipient for peace of mind.",
        imageDescription: "App mockup: recipient cards with photo, name, and relationship label",
        chips: [OBChip(icon: "ob-users", label: "Up to 50 people", illustration: "ob-item-people"),
                OBChip(icon: "ob-shield-check", label: "Backup recipient", illustration: "ob-item-backup")]
    )

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

    // MARK: - Paywall

    struct OBPaywallCard: Identifiable {
        let id = UUID()
        let title: String
        let imageDescription: String
        let reviewQuote: String
        let reviewer: String
    }

    static let paywallCards: [OBPaywallCard] = [
        OBPaywallCard(title: "Unlimited messages",
                      imageDescription: "Illustration: a stack of sealed messages, warm and full",
                      reviewQuote: "I've recorded one for every birthday until she turns 18.",
                      reviewer: "Sarah, 34"),
        OBPaywallCard(title: "Critical Timed Messages",
                      imageDescription: "Illustration: a calm clock with a soft protective glow",
                      reviewQuote: "Knowing my family will hear from me no matter what lets me sleep.",
                      reviewer: "Michael, 47"),
        OBPaywallCard(title: "Up to 50 recipients",
                      imageDescription: "Illustration: a small circle of people connected by soft light",
                      reviewQuote: "My whole family is in here now. Everyone has something waiting.",
                      reviewer: "Elena, 58"),
        OBPaywallCard(title: "End-to-end encryption and secure backup",
                      imageDescription: "Illustration: a shield over a vault, calm and solid",
                      reviewQuote: "These are my most private words. It matters that they're truly safe.",
                      reviewer: "David, 41")
    ]
}
