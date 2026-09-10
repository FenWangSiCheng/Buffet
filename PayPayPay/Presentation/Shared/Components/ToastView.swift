import SwiftUI

/// Presents a transient message over the content it modifies.
struct ToastModifier: ViewModifier {
    let message: String?
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        ZStack {
            content.blur(radius: message == nil ? 0 : 1)

            if let message {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(maxWidth: 240)
                    .background(.regularMaterial,
                                in: .rect(cornerRadius: Theme.toastCornerRadius))
                    .transition(transition)
                    .task(id: message) {
                        try? await Task.sleep(for: Theme.toastDuration)
                        guard !Task.isCancelled else { return }
                        onDismiss()
                    }
            }
        }
        .animation(reduceMotion ? nil : .bouncy, value: message)
    }

    private var transition: AnyTransition {
        reduceMotion ? .opacity : .opacity.combined(with: .scale)
    }
}

extension View {
    /// Shows `message` as a toast for a couple of seconds, then calls `onDismiss`.
    func toast(message: String?, onDismiss: @escaping () -> Void) -> some View {
        modifier(ToastModifier(message: message, onDismiss: onDismiss))
    }
}
