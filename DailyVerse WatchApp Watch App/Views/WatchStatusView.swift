//
//  WatchStatusView.swift
//  DailyVerse WatchApp Watch App
//

import SwiftUI

struct WatchStatusView: View {
    enum Style {
        case info
        case warning
        case error
        case loading
    }

    let message: String
    let style: Style

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            if style == .loading {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: iconName)
                    .font(.system(size: 11, weight: .semibold))
            }

            Text(message)
                .font(WatchAppTheme.Typography.status)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(statusColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: WatchAppTheme.Metrics.statusCornerRadius, style: .continuous)
                .fill(statusColor.opacity(0.12))
        )
    }

    private var iconName: String {
        switch style {
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.octagon.fill"
        case .loading:
            return "clock"
        }
    }

    private var statusColor: Color {
        switch style {
        case .info, .loading:
            return WatchAppTheme.Colors.statusInfo(for: colorScheme)
        case .warning:
            return WatchAppTheme.Colors.statusWarning(for: colorScheme)
        case .error:
            return WatchAppTheme.Colors.statusError(for: colorScheme)
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        WatchStatusView(message: "Warte auf iPhone-Synchronisierung", style: .loading)
        WatchStatusView(message: "Offline: Letzter synchronisierter Vers", style: .warning)
        WatchStatusView(message: "Alles synchron", style: .info)
    }
    .padding()
}
