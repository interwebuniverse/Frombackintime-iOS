//
//  AudioRecorder.swift
//  FromBackInTime
//
//  Minimal AVAudioRecorder wrapper for voice notes. Records AAC into a temp
//  .m4a file (matches the backend's allowed audio/m4a content type) and hands
//  back the raw bytes for the R2 upload.
//

import Foundation
import AVFoundation

@MainActor
@Observable
final class AudioRecorder {
    private var recorder: AVAudioRecorder?
    private(set) var fileURL: URL?

    func start() async {
        let granted = await AVAudioApplication.requestRecordPermission()
        guard granted else { return }

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("ftbi-voice-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        recorder = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        fileURL = url
    }

    func stop() {
        recorder?.stop()
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func data() -> Data? {
        guard let fileURL else { return nil }
        return try? Data(contentsOf: fileURL)
    }
}
