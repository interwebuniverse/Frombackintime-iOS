//
//  AudioRecorder.swift
//  FromBackInTime
//
//  Minimal AVAudioRecorder wrapper for voice notes. Records AAC into a temp
//  .m4a file (matches the backend's allowed audio/m4a content type) and hands
//  back the raw bytes for the R2 upload. Permission is handled by the caller
//  via MediaPermission before `start()` is called; `start()` reports whether
//  recording actually began so the UI never shows a fake "recording" state.
//

import Foundation
import AVFoundation

@MainActor
@Observable
final class AudioRecorder {
    private var recorder: AVAudioRecorder?
    private(set) var fileURL: URL?

    /// Begins recording. Returns false if the session or recorder could not be
    /// set up (denied access, hardware busy, interruption), so the caller can
    /// stay in the idle state instead of ticking a timer over nothing.
    @discardableResult
    func start() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            return false
        }

        // Drop any file from a prior take so retakes don't pile up temp .m4a files.
        removeFile()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("ftbi-voice-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        guard let rec = try? AVAudioRecorder(url: url, settings: settings), rec.record() else {
            return false
        }
        recorder = rec
        fileURL = url
        return true
    }

    /// True while a recording is actively capturing audio.
    var isRecording: Bool { recorder?.isRecording ?? false }

    func stop() {
        recorder?.stop()
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    /// The recorded bytes, or nil if nothing usable was captured.
    func data() -> Data? {
        guard let fileURL, let data = try? Data(contentsOf: fileURL), !data.isEmpty else { return nil }
        return data
    }

    /// Removes the on-disk recording. Call once the bytes have been uploaded or
    /// the take is abandoned so the temp directory doesn't accumulate .m4a files.
    func cleanup() {
        removeFile()
    }

    private func removeFile() {
        if let fileURL { try? FileManager.default.removeItem(at: fileURL) }
        fileURL = nil
    }
}
