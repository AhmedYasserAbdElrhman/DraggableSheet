import SwiftUI

// MARK: - SheetScrollState

/// Shared reference type for scroll offset communication between
/// `DraggableSheetView` (reader) and `SheetScrollView` (writer).
///
/// Passed through the SwiftUI environment so that `SheetScrollView`
/// can write the current scroll offset directly, and the gesture
/// closure in `DraggableSheetView` always reads the latest value
/// without relying on `PreferenceKey` (which doesn't update during scroll).
@MainActor final class SheetScrollState {
    /// Current vertical scroll offset. Positive = scrolled down.
    var offset: CGFloat = 0
    /// True when a `SheetScrollView` is present in the content.
    var hasScrollContent: Bool = false
    /// Gesture decision flag — lives here (not `@State`) to avoid triggering view re-evaluation.
    var gestureDecided: Bool = false
}

// MARK: - Coordinate Space

internal let sheetScrollCoordinateSpace = "sheetScroll"

// MARK: - Environment Key

struct SheetScrollStateKey: EnvironmentKey {
    static let defaultValue: SheetScrollState? = nil
}

extension EnvironmentValues {
    var sheetScrollState: SheetScrollState? {
        get { self[SheetScrollStateKey.self] }
        set { self[SheetScrollStateKey.self] = newValue }
    }
}

