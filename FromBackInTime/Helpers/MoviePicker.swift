//
//  MoviePicker.swift
//  FromBackInTime
//
//  System camera for capturing a real video message. Kept minimal via
//  UIImagePickerController (front camera, movie). On the simulator (no camera)
//  it falls back to the photo library so the flow is still testable. Returns the
//  recorded file's bytes and its duration in seconds.
//

import SwiftUI
import UIKit
import AVFoundation
import UniformTypeIdentifiers

struct MoviePicker: UIViewControllerRepresentable {
    /// (bytes, duration in seconds, MIME content type). Content type reflects the
    /// actual file the camera or library produced (video/quicktime vs video/mp4),
    /// both of which the backend accepts, so the R2 object is labelled correctly.
    var onComplete: (Data?, Int, String) -> Void

    /// Cap so a runaway recording can't buffer hundreds of MB into memory.
    static let maxDuration: TimeInterval = 5 * 60

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .video
            picker.cameraDevice = .front
            picker.videoMaximumDuration = Self.maxDuration
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.mediaTypes = [UTType.movie.identifier]
        picker.videoQuality = .typeHigh
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onComplete: onComplete) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onComplete: (Data?, Int, String) -> Void

        init(onComplete: @escaping (Data?, Int, String) -> Void) {
            self.onComplete = onComplete
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let onComplete = self.onComplete
            guard let url = info[.mediaURL] as? URL else {
                picker.dismiss(animated: true)
                onComplete(nil, 0, "video/mp4")
                return
            }
            // Dismiss immediately, then read the (potentially several-hundred-MB)
            // clip off the main thread so the UI never hangs on the file load.
            picker.dismiss(animated: true) {
                Task.detached(priority: .userInitiated) {
                    let data = try? Data(contentsOf: url)
                    let seconds = CMTimeGetSeconds(AVURLAsset(url: url).duration)
                    let duration = seconds.isFinite ? Int(seconds.rounded()) : 0
                    let contentType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "video/mp4"
                    await MainActor.run { onComplete(data, max(duration, 1), contentType) }
                }
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onComplete(nil, 0, "video/mp4")
        }
    }
}
