import SwiftUI

extension View {
    /// Uses Liquid Glass on iOS 26 and a system material on earlier releases.
    @ViewBuilder
    func adaptiveGlassBackground(cornerRadius: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(in: .rect(cornerRadius: cornerRadius))
        } else {
            background(.regularMaterial, in: .rect(cornerRadius: cornerRadius))
        }
    }

    /// Uses the native prominent glass button while preserving the iOS 18 fallback.
    @ViewBuilder
    func adaptiveProminentButtonStyle(tint: Color) -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glassProminent)
                .tint(tint)
        } else {
            buttonStyle(.borderedProminent)
                .tint(tint)
        }
    }

    /// Lets the system collapse the floating tab bar as scrollable content moves down.
    @ViewBuilder
    func adaptiveTabBarMinimizeBehavior() -> some View {
        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }
}
