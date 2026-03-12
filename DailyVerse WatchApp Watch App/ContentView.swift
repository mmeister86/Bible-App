//
//  ContentView.swift
//  DailyVerse WatchApp Watch App
//
//  Created by Matthias Meister on 07.03.26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = WatchDailyVerseViewModel()
    @Environment(\.colorScheme) private var colorScheme

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

    var body: some View {
        ZStack {
            WatchAppTheme.Colors.backgroundGradient(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: WatchAppTheme.Metrics.sectionSpacing) {
                    Text("Daily Verse")
                        .font(WatchAppTheme.Typography.title)
                        .foregroundStyle(WatchAppTheme.Colors.accentGold(for: colorScheme))

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

                    randomVerseButton
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, WatchAppTheme.Metrics.horizontalPadding)
                .padding(.vertical, 4)
            }
        }
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
                    Image(systemName: "sparkles")
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
                    .fill(WatchAppTheme.Colors.accentGold(for: colorScheme))
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isRandomVerseLoading)
        .opacity(viewModel.isRandomVerseLoading ? 0.8 : 1.0)
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
}

#Preview {
    ContentView()
}
