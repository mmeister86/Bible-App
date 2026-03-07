//
//  ContentView.swift
//  DailyVerse WatchApp Watch App
//
//  Created by Matthias Meister on 07.03.26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = WatchDailyVerseViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Daily Verse")
                    .font(.headline)

                if let verse = viewModel.verse {
                    Text(verse.text.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.body)

                    Text(verse.reference)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Text(viewModel.selectedTranslation.uppercased())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Noch kein synchronisierter Tagesvers")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if let statusMessage = viewModel.statusMessage {
                    Text(statusMessage)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Button {
                    Task {
                        await viewModel.requestRandomVerse()
                    }
                } label: {
                    if viewModel.isRandomVerseLoading {
                        ProgressView()
                    } else {
                        Text("Random Verse")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isRandomVerseLoading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    ContentView()
}
