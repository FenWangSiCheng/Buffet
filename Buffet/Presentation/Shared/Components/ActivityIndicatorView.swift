import SwiftUI

struct ActivityIndicatorView: View {
    let isAnimating: Bool

    var body: some View {
        if isAnimating {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
        }
    }
}
