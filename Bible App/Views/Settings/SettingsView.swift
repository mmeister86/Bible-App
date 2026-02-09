//
//  SettingsView.swift
//  Bible App
//

import SwiftUI

/// Settings screen with translation picker, appearance toggle,
/// font size slider, display preferences, and about section.
/// Includes haptic feedback on reset and smooth animation for live preview.
struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var resetTriggered = false
    @State private var showResetConfirmation = false
    @State private var sliderFontSize: Double = 20.0

    var body: some View {
        NavigationStack {
            Form {
                translationSection
                appearanceSection
                readingSection
                displaySection
                notificationSection
                aboutSection
                resetSection
            }
            .navigationTitle("Settings")
            .onAppear {
                sliderFontSize = viewModel.fontSize
            }
        }
        .sensoryFeedback(.warning, trigger: resetTriggered)
    }

    // MARK: - Translation

    private var translationSection: some View {
        Section {
            Picker("Bible Translation", selection: $viewModel.selectedTranslation) {
                ForEach(SettingsViewModel.availableTranslations) { translation in
                    Text(translation.name).tag(translation.id)
                }
            }
            .pickerStyle(.navigationLink)
        } header: {
            Label("Translation", systemImage: "book.fill")
                .foregroundStyle(Color.accentGold)
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        Section {
            Picker("Appearance", selection: $viewModel.appearanceMode) {
                ForEach(AppearanceMode.allCases, id: \.rawValue) { mode in
                    Text(mode.label).tag(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Label("Appearance", systemImage: "circle.lefthalf.filled")
                .foregroundStyle(Color.accentGold)
        }
    }

    // MARK: - Reading

    private var readingSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Font Size")
                    Spacer()
                    Text("\(Int(sliderFontSize))pt")
                        .foregroundStyle(Color.secondaryText)
                        .monospacedDigit()
                }

                Slider(value: $sliderFontSize, in: 16...32, step: 1) { editing in
                    if !editing {
                        viewModel.commitFontSize(sliderFontSize)
                    }
                }
                .tint(Color.accentGold)

                // Live preview with animation
                Text("For God so loved the world...")
                    .font(.system(size: sliderFontSize, design: .serif))
                    .foregroundStyle(Color.primaryText)
                    .lineSpacing(6)
                    .animation(.easeInOut(duration: 0.15), value: sliderFontSize)
            }
        } header: {
            Label("Reading", systemImage: "textformat.size")
                .foregroundStyle(Color.accentGold)
        }
    }

    // MARK: - Display

    private var displaySection: some View {
        Section {
            Toggle("Show Verse Numbers", isOn: $viewModel.showVerseNumbers)
                .tint(Color.accentGold)
        } header: {
            Label("Display", systemImage: "eye.fill")
                .foregroundStyle(Color.accentGold)
        }
    }

    // MARK: - Notifications

    private var notificationSection: some View {
        Section {
            Toggle("Daily Reminder", isOn: Binding(
                get: { viewModel.notificationsEnabled },
                set: { newValue in
                    if newValue {
                        Task {
                            await viewModel.enableNotifications()
                        }
                    } else {
                        viewModel.disableNotifications()
                    }
                }
            ))
            .tint(Color.accentGold)

            if viewModel.notificationPermissionDenied {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Notifications are disabled in system settings.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                }

                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    Link(destination: settingsURL) {
                        HStack {
                            Text("Open Settings")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(Color.accentGold)
                        }
                    }
                }
            }

            if viewModel.notificationsEnabled {
                DatePicker(
                    "Reminder Time",
                    selection: $viewModel.reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .tint(Color.accentGold)
            }
        } header: {
            Label("Notifications", systemImage: "bell.fill")
                .foregroundStyle(Color.accentGold)
        } footer: {
            if viewModel.notificationsEnabled {
                Text("You'll receive a daily reminder to read your verse.")
                    .foregroundStyle(Color.secondaryText)
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(Color.secondaryText)
            }

            HStack {
                Text("API")
                Spacer()
                Text("Powered by bible-api.com")
                    .foregroundStyle(Color.secondaryText)
            }

            if let url = URL(string: "https://bible-api.com") {
                Link(destination: url) {
                    HStack {
                        Text("Visit bible-api.com")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(Color.accentGold)
                    }
                }
            }
        } header: {
            Label("About", systemImage: "info.circle.fill")
                .foregroundStyle(Color.accentGold)
        }
    }

    // MARK: - Reset

    private var resetSection: some View {
        Section {
            Button("Reset to Defaults", role: .destructive) {
                showResetConfirmation = true
            }
            .confirmationDialog(
                "Reset all settings to defaults?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    withAnimation {
                        viewModel.resetToDefaults()
                        sliderFontSize = viewModel.fontSize
                    }
                    resetTriggered.toggle()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will reset your translation, appearance, font size, display, and notification preferences.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
