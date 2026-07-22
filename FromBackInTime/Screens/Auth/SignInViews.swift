//
//  SignInViews.swift
//  FromBackInTime
//
//  Shared sign-in UI. SignInControls is the Apple + Google button pair with
//  the full token dance; the onboarding auth gate and the in-app SignInSheet
//  both render it. SignInSheet is the gate shown when an anonymous user tries
//  to create something that must belong to a real account (recipients,
//  messages), so nothing is ever created under a throwaway identity.
//

import AuthenticationServices
import SwiftUI

// MARK: - Apple + Google buttons

struct SignInControls: View {
    @Environment(AuthStore.self) private var authStore

    /// Called only after a successful, non-anonymous sign-in.
    var onSignedIn: () -> Void = {}
    /// Called with the given name Apple shares on first authorization.
    var onAppleName: (String) -> Void = { _ in }

    /// Raw nonce for the in-flight Apple request. Apple gets its SHA-256,
    /// Supabase gets the raw value to verify the token claim.
    @State private var appleNonce = SignInCrypto.randomURLSafe()
    @State private var isWorking = false

    /// Flip to true once the Google OAuth consent screen is verified.
    private let showGoogle = false

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            if let error = authStore.state.error {
                Text(error)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appError)
                    .multilineTextAlignment(.center)
            }

            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.fullName, .email]
                request.nonce = SignInCrypto.sha256Hex(appleNonce)
            } onCompletion: { result in
                handleApple(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 58)
            .clipShape(.capsule)
            .shadow(color: .black.opacity(0.16), radius: 16, y: 8)
            .a11y("signin.apple")

            // Google sign-in is hidden for launch: shipping it requires Google's
            // OAuth consent-screen verification. The full flow (signInWithGoogle,
            // GoogleAuthSession, backend PKCE) stays wired; re-add the button here
            // once Google approves the app.
            if showGoogle {
                Button {
                    signInWithGoogle()
                } label: {
                    HStack(spacing: AppSpacing.sm + 2) {
                        Image("ob-google-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        Text("Continue with Google")
                            .font(.system(size: 19, weight: .medium))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(Color.white, in: .capsule)
                    .overlay(Capsule().strokeBorder(Color.black.opacity(0.12), lineWidth: 1))
                    .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
                }
                .obBounce(scale: 0.98)
                .a11y("signin.google")
            }
        }
        .opacity(isWorking ? 0.5 : 1)
        .disabled(isWorking)
        .overlay {
            if isWorking { ProgressView().tint(OnboardingTheme.title) }
        }
        // A stale error from a previous attempt shouldn't greet the next one.
        .onAppear { authStore.state.error = nil }
    }

    private func handleApple(_ result: Result<ASAuthorization, Error>) {
        // A real failure (config problem, network, invalid response) should be
        // shown; only a deliberate cancel is silent.
        if case .failure(let error) = result {
            if let asError = error as? ASAuthorizationError, asError.code == .canceled { return }
            authStore.state.error = "Sign in with Apple didn't complete. Please try again."
            return
        }
        guard case .success(let authorization) = result,
              let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            authStore.state.error = "Sign in with Apple didn't return the expected credentials. Please try again."
            return
        }
        // Apple shares the name only on the very first authorization.
        if let given = credential.fullName?.givenName, !given.isEmpty {
            onAppleName(given)
        }
        let nonce = appleNonce
        appleNonce = SignInCrypto.randomURLSafe()   // one nonce per attempt
        isWorking = true
        Task {
            await authStore.signInWithApple(idToken: idToken, nonce: nonce)
            isWorking = false
            completeIfSignedIn()
        }
    }

    private func signInWithGoogle() {
        isWorking = true
        Task {
            await authStore.signInWithGoogle()
            isWorking = false
            completeIfSignedIn()
        }
    }

    private func completeIfSignedIn() {
        guard authStore.state.isAuthenticated, !authStore.state.isAnonymous else { return }
        Haptics.notification(type: .success)
        onSignedIn()
    }
}

// MARK: - In-app sign-in gate sheet

struct SignInSheet: View {
    @Environment(\.dismiss) private var dismiss

    var subtitle = "Sign in so your messages outlive this phone and no one else can ever claim them."
    /// Runs after the sheet dismisses on a successful sign-in, e.g. to retry
    /// the action that was gated.
    var onSignedIn: () -> Void = {}

    private static let skyBottom = Color(red: 200/255, green: 222/255, blue: 240/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-vault")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, Self.skyBottom.opacity(0.5), Self.skyBottom.opacity(0.96)],
                startPoint: .center, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()

                Image("ob-d-shield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 84, height: 84)
                    .padding(.bottom, AppSpacing.lg)

                VStack(spacing: AppSpacing.sm) {
                    Text("Make your vault yours.")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, AppSpacing.xxl)

                SignInControls(onSignedIn: {
                    dismiss()
                    onSignedIn()
                })

                Button("Not now") { dismiss() }
                    .textButton()
                    .padding(.top, AppSpacing.lg)
                    .a11y("signin.skip")
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
        .presentationCornerRadius(28)
    }
}

// MARK: - Save gating

// Shared chrome for the create flows: the sign-in gate sheet plus the
// save-error alert. The view keeps the state; this keeps the plumbing.
struct SaveGating: ViewModifier {
    @Binding var showSignIn: Bool
    @Binding var error: String?
    let signInSubtitle: String
    let retry: () -> Void

    func body(content: Content) -> some View {
        content
            .alert("Couldn't save", isPresented: Binding(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(error ?? "")
            }
            .sheet(isPresented: $showSignIn) {
                SignInSheet(subtitle: signInSubtitle, onSignedIn: retry)
            }
    }
}

extension View {
    func saveGating(
        showSignIn: Binding<Bool>,
        error: Binding<String?>,
        signInSubtitle: String,
        retry: @escaping () -> Void
    ) -> some View {
        modifier(SaveGating(
            showSignIn: showSignIn,
            error: error,
            signInSubtitle: signInSubtitle,
            retry: retry
        ))
    }
}
