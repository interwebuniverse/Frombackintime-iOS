//
//  L10n.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//
//  Type-safe localization keys. Each case maps to a key in
//  Localizable.strings. Access via `L10n.commonOk.localized`.
//
//  For format strings: `L10n.someFormat.localized(with: value)`

import Foundation

enum L10n: String {

    // MARK: - Common

    case commonOk = "common.ok"
    case commonCancel = "common.cancel"
    case commonDone = "common.done"
    case commonSave = "common.save"
    case commonDelete = "common.delete"
    case commonEdit = "common.edit"
    case commonClose = "common.close"
    case commonBack = "common.back"
    case commonNext = "common.next"
    case commonContinue = "common.continue"
    case commonRetry = "common.retry"
    case commonLoading = "common.loading"
    case commonError = "common.error"
    case commonSuccess = "common.success"
    case commonSearch = "common.search"
    case commonYes = "common.yes"
    case commonNo = "common.no"

    // MARK: - Launch

    case launchTitle = "launch.title"
    case launchOpenExample = "launch.open_example"
    case launchOnboarding = "launch.onboarding"

    // MARK: - Example

    case exampleTitle = "example.title"
    case exampleEmpty = "example.empty"
    case exampleRetry = "example.retry"

    // MARK: - Errors

    case errorNetwork = "error.network"
    case errorUnauthorized = "error.unauthorized"
    case errorServer = "error.server"
    case errorUnknown = "error.unknown"

    // MARK: - Computed

    var localized: String {
        rawValue.localized
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}
