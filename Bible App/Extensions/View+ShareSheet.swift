//
//  View+ShareSheet.swift
//  Bible App
//

import SwiftUI

// MARK: - Share Sheet Modifier

extension View {
    /// Present a system share sheet (UIActivityViewController) as a sheet.
    func shareSheet(isPresented: Binding<Bool>, items: [Any]) -> some View {
        self.sheet(isPresented: isPresented) {
            ActivityViewController(activityItems: items)
                .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - UIActivityViewController Wrapper

/// A `UIViewControllerRepresentable` bridge for `UIActivityViewController`.
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {
        // No updates needed
    }
}
