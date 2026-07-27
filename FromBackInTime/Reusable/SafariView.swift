//
//  SafariView.swift
//  FromBackInTime
//
//  SFSafariViewController wrapped for SwiftUI. Use this for legal pages
//  (privacy, terms) so the user reads them without being thrown out of the
//  app into Safari and losing their place in a flow.
//
//  Usage:
//    .sheet(isPresented: $show) { SafariView(url: someURL) }
//

import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false

        let controller = SFSafariViewController(url: url, configuration: config)
        controller.preferredControlTintColor = UIColor(AppShellTheme.accent)
        controller.dismissButtonStyle = .done
        return controller
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}

/// The app's legal pages, in one place so every link points at the same URLs.
/// Identifiable so a view can drive a Safari sheet with `.sheet(item:)`.
struct LegalPage: Identifiable {
    let id: String
    let url: URL

    static let privacy = LegalPage(id: "privacy", url: URL(string: "https://frombackintime.com/privacy")!)
    static let terms = LegalPage(id: "terms", url: URL(string: "https://frombackintime.com/terms")!)
}
