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
    var onComplete: (Data?, Int) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .video
            picker.cameraDevice = .front
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
        let onComplete: (Data?, Int) -> Void

        init(onComplete: @escaping (Data?, Int) -> Void) {
            self.onComplete = onComplete
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            var data: Data?
            var duration = 0
            if let url = info[.mediaURL] as? URL {
                data = try? Data(contentsOf: url)
                let seconds = CMTimeGetSeconds(AVURLAsset(url: url).duration)
                if seconds.isFinite { duration = Int(seconds.rounded()) }
            }
            picker.dismiss(animated: true)
            onComplete(data, max(duration, 1))
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onComplete(nil, 0)
        }
    }
}
