import CoreGraphics

/// Shared design constants, so spacing and rounding stay consistent across screens.
enum Theme {
    /// Apple's minimum recommended tappable size on iOS.
    static let minimumTapSize: CGFloat = 44
    static let thumbnailSize: CGFloat = 120
    static let rowPadding: CGFloat = 10
    static let toastCornerRadius: CGFloat = 20
    static let toastDuration: Duration = .seconds(2)
}
