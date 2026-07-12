//
//  MediaPermission.swift
//  FromBackInTime
//
//  One place for camera + microphone permission. The flow the whole app uses:
//  not-determined -> ask the system; granted -> go; denied (now or before) ->
//  show a "turn it on in Settings" alert with a deep link. Capture screens call
//  `ensure(_:)` before recording and, on false, set `deniedPermission` to drive
//  the shared `.permissionAlert` modifier.
//

import AVFoundation
import SwiftUI
import UIKit

enum MediaPermission {
    enum Kind: Identifiable {
        case microphone
        case camera

        var id: String { self == .microphone ? "microphone" : "camera" }

        var deniedTitle: String {
            switch self {
            case .microphone: return "Microphone is off"
            case .camera:     return "Camera is off"
            }
        }

        var deniedMessage: String {
            switch self {
            case .microphone:
                return "To record your voice, turn on Microphone access for FromBackInTime in Settings."
            case .camera:
                return "To record a video, turn on Camera access for FromBackInTime in Settings."
            }
        }
    }

    enum State { case granted, denied, undetermined }

    static func state(_ kind: Kind) -> State {
        switch kind {
        case .microphone:
            switch AVAudioApplication.shared.recordPermission {
            case .granted:    return .granted
            case .denied:     return .denied
            default:          return .undetermined
            }
        case .camera:
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:            return .granted
            case .denied, .restricted:   return .denied
            default:                     return .undetermined
            }
        }
    }

    /// Ask the system when the choice hasn't been made yet.
    static func request(_ kind: Kind) async -> Bool {
        switch kind {
        case .microphone: return await AVAudioApplication.requestRecordPermission()
        case .camera:     return await AVCaptureDevice.requestAccess(for: .video)
        }
    }

    /// Returns true only when the app may proceed. When it returns false the
    /// caller should surface the Settings alert (the user has denied access,
    /// either just now on the first prompt or in a previous session).
    static func ensure(_ kind: Kind) async -> Bool {
        switch state(kind) {
        case .granted:      return true
        case .denied:       return false
        case .undetermined: return await request(kind)
        }
    }

    @MainActor
    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Settings alert

private struct PermissionAlert: ViewModifier {
    @Binding var deniedKind: MediaPermission.Kind?

    func body(content: Content) -> some View {
        content.alert(
            deniedKind?.deniedTitle ?? "",
            isPresented: Binding(
                get: { deniedKind != nil },
                set: { if !$0 { deniedKind = nil } }
            ),
            presenting: deniedKind
        ) { _ in
            Button("Open Settings") {
                MediaPermission.openSettings()
                deniedKind = nil
            }
            Button("Not now", role: .cancel) { deniedKind = nil }
        } message: { kind in
            Text(kind.deniedMessage)
        }
    }
}

extension View {
    /// Presents the "turn it on in Settings" alert whenever `deniedKind` is set.
    func permissionAlert(_ deniedKind: Binding<MediaPermission.Kind?>) -> some View {
        modifier(PermissionAlert(deniedKind: deniedKind))
    }
}
