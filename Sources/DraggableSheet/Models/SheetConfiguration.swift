import SwiftUI

// MARK: - SheetConfiguration

/// Styling and behavior options for `DraggableSheetView`.
///
/// ```swift
/// var config = SheetConfiguration()
/// config.cornerRadius = 24
/// config.backgroundColor = .black
/// config.showHandle = false
/// ```
public struct SheetConfiguration: Equatable {

    // Animation doesn't conform to Equatable — compare all other fields.
    // Two configs with the same visible properties are considered equal.
    public static func == (lhs: SheetConfiguration, rhs: SheetConfiguration) -> Bool {
        lhs.cornerRadius == rhs.cornerRadius
            && lhs.backgroundColor == rhs.backgroundColor
            && lhs.shadowRadius == rhs.shadowRadius
            && lhs.showHandle == rhs.showHandle
            && lhs.handleColor == rhs.handleColor
            && lhs.handleSize == rhs.handleSize
            && lhs.dragThreshold == rhs.dragThreshold
    }

    // MARK: - Appearance

    /// Corner radius applied to the top-leading and top-trailing corners.
    public var cornerRadius: CGFloat

    /// Background color of the sheet surface.
    public var backgroundColor: Color

    /// Shadow radius behind the sheet.
    public var shadowRadius: CGFloat

    // MARK: - Handle

    /// Whether the drag handle indicator is visible.
    public var showHandle: Bool

    /// Color of the drag handle capsule.
    public var handleColor: Color

    /// Size of the drag handle capsule (width × height).
    public var handleSize: CGSize

    // MARK: - Behavior

    /// Minimum drag distance (in points) required to trigger a position snap.
    public var dragThreshold: CGFloat

    /// Spring animation used for snapping.
    public var animation: Animation

    // MARK: - Init

    public init(
        cornerRadius: CGFloat = 16,
        backgroundColor: Color = .white,
        shadowRadius: CGFloat = 4,
        showHandle: Bool = true,
        handleColor: Color = Color.gray.opacity(0.5),
        handleSize: CGSize = CGSize(width: 40, height: 5),
        dragThreshold: CGFloat = 50,
        animation: Animation = .interactiveSpring(response: 0.4, dampingFraction: 0.8)
    ) {
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.shadowRadius = shadowRadius
        self.showHandle = showHandle
        self.handleColor = handleColor
        self.handleSize = handleSize
        self.dragThreshold = dragThreshold
        self.animation = animation
    }
}
