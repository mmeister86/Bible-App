//
//  TabHeaderView.swift
//  Bible App
//

import SwiftUI

/// Shared tab header with a fixed subtitle row height for consistent alignment.
struct TabHeaderView: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(AppTheme.heading)
                .foregroundStyle(Color.primaryText)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(AppTheme.caption)
                    .foregroundStyle(Color.secondaryText)
                    .lineLimit(1)
            } else {
                Text(" ")
                    .font(AppTheme.caption)
                    .hidden()
                    .accessibilityHidden(true)
            }
        }
        .padding(.top, AppTheme.sectionGap)
        .padding(.bottom, AppTheme.screenMargin)
    }
}

#Preview {
    VStack(spacing: 0) {
        TabHeaderView(title: "Search")
        TabHeaderView(title: "Today", subtitle: "Saturday, February 7")
    }
    .padding()
}
