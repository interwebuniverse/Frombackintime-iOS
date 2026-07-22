//
//  AudioPlayback.swift
//  FromBackInTime
//
//  Minimal AVAudioPlayer wrapper so a just-recorded voice note can be reviewed
//  before saving. Plays through the speaker (audible with the mute switch on),
//  reports progress for a scrub bar, and resets to the start when the clip ends.
//

import AVFoundation
import Foundation

@MainActor
@Observable
final class AudioPlayback: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private(set) var isPlaying = false

    /// 0...1 through the clip. Read inside a TimelineView tick for live updates.
    var progress: Double {
        guard let player, player.duration > 0 else { return 0 }
        return min(player.currentTime / player.duration, 1)
    }

    var currentTime: TimeInterval { player?.currentTime ?? 0 }
    var duration: TimeInterval { player?.duration ?? 0 }

    /// Play from the start (or resume), or pause if already playing.
    func toggle(url: URL) {
        if isPlaying {
            player?.pause()
            isPlaying = false
            return
        }
        if player == nil || player?.url != url {
            player = try? AVAudioPlayer(contentsOf: url)
            player?.delegate = self
        }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)
        guard player?.play() == true else { return }
        isPlaying = true
    }

    /// Stop and forget the clip (retake, save, or leaving the screen).
    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.player?.currentTime = 0
        }
    }
}
