//
//  ContentView.swift
//  DailyVerse WatchApp Watch App
//
//  Created by Matthias Meister on 07.03.26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = WatchDailyVerseViewModel()
    @AppStorage("appearanceMode") private var appearanceModeRawValue: Int = WatchAppearanceMode.system.rawValue
    @Environment(\.colorScheme) private var systemColorScheme

    private enum ScreenState {
        case verse(BibleResponse)
        case loading
        case empty(message: String)
    }

    private var screenState: ScreenState {
        if let verse = viewModel.verse {
            return .verse(verse)
        }

        if viewModel.isRandomVerseLoading {
            return .loading
        }

        return .empty(message: viewModel.statusMessage ?? "Noch kein synchronisierter Tagesvers")
    }

    private var selectedAppearanceMode: WatchAppearanceMode {
        WatchAppearanceMode(rawValue: appearanceModeRawValue) ?? .system
    }

    private var effectiveColorScheme: ColorScheme {
        switch selectedAppearanceMode {
        case .system:
            systemColorScheme
        case .light:
            .light
        case .dark:
            .dark
        }
    }

    var body: some View {
        ZStack {
            WatchAppTheme.Colors.backgroundGradient(for: effectiveColorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: WatchAppTheme.Metrics.sectionSpacing) {
                    Text("Daily Verse")
                        .font(WatchAppTheme.Typography.title)
                        .foregroundStyle(WatchAppTheme.Colors.accentGold(for: effectiveColorScheme))

                    switch screenState {
                    case .verse(let verse):
                        WatchVerseCardView(
                            verse: verse,
                            selectedTranslation: viewModel.selectedTranslation
                        )
                    case .loading:
                        WatchStatusView(
                            message: "Vers wird geladen ...",
                            style: .loading
                        )
                    case .empty(let message):
                        WatchStatusView(
                            message: message,
                            style: .info
                        )
                    }

                    if let statusMessage = viewModel.statusMessage, case .verse = screenState {
                        WatchStatusView(
                            message: statusMessage,
                            style: statusStyle(for: statusMessage)
                        )
                    }

                    appearanceModeSwitcher

                    randomVerseButton

                    if viewModel.isShowingRandomVerse {
                        showDailyVerseButton
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, WatchAppTheme.Metrics.horizontalPadding)
                .padding(.vertical, 4)
            }
            .environment(\.colorScheme, effectiveColorScheme)
        }
    }

    private var appearanceModeSwitcher: some View {
        HStack(spacing: 6) {
            ForEach(WatchAppearanceMode.allCases, id: \.rawValue) { mode in
                Button {
                    appearanceModeRawValue = mode.rawValue
                } label: {
                    Text(buttonLabel(for: mode))
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 24)
                        .background(
                            Capsule(style: .continuous)
                                .fill(
                                    selectedAppearanceMode == mode
                                        ? WatchAppTheme.Colors.accentGold(for: effectiveColorScheme)
                                        : WatchAppTheme.Colors.cardBackground(for: effectiveColorScheme)
                                )
                        )
                        .foregroundStyle(
                            selectedAppearanceMode == mode
                                ? Color.black
                                : WatchAppTheme.Colors.primaryText(for: effectiveColorScheme)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Appearance")
    }

    private var randomVerseButton: some View {
        Button {
            Task {
                await viewModel.requestRandomVerse()
            }
        } label: {
            HStack(spacing: 6) {
                if viewModel.isRandomVerseLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "shuffle")
                        .font(.system(size: 12, weight: .semibold))
                }

                Text("Random Verse")
                    .font(WatchAppTheme.Typography.button)
            }
            .frame(maxWidth: .infinity)
            .frame(height: WatchAppTheme.Metrics.buttonHeight)
            .foregroundStyle(Color.black)
            .background(
                RoundedRectangle(cornerRadius: WatchAppTheme.Metrics.buttonCornerRadius, style: .continuous)
                    .fill(WatchAppTheme.Colors.accentGold(for: effectiveColorScheme))
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isRandomVerseLoading)
        .opacity(viewModel.isRandomVerseLoading ? 0.8 : 1.0)
    }

    private var showDailyVerseButton: some View {
        Button {
            viewModel.showDailyVerse()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 12, weight: .semibold))

                Text("Show Daily Verse")
                    .font(WatchAppTheme.Typography.button)
            }
            .frame(maxWidth: .infinity)
            .frame(height: WatchAppTheme.Metrics.buttonHeight)
            .foregroundStyle(WatchAppTheme.Colors.primaryText(for: effectiveColorScheme))
            .background(
                RoundedRectangle(cornerRadius: WatchAppTheme.Metrics.buttonCornerRadius, style: .continuous)
                    .fill(WatchAppTheme.Colors.cardBackground(for: effectiveColorScheme))
            )
        }
        .buttonStyle(.plain)
    }

    private func statusStyle(for message: String) -> WatchStatusView.Style {
        let normalizedMessage = message.lowercased()

        if normalizedMessage.contains("fehler") || normalizedMessage.contains("error") || normalizedMessage.contains("invalid") {
            return .error
        }

        if normalizedMessage.contains("offline") || normalizedMessage.contains("nicht erreichbar") {
            return .warning
        }

        if normalizedMessage.contains("warte") {
            return .loading
        }

        return .info
    }

    private func buttonLabel(for mode: WatchAppearanceMode) -> String {
        switch mode {
        case .system: "Sys"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

#Preview {
    ContentView()
}
