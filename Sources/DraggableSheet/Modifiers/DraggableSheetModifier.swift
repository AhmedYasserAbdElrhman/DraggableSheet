import SwiftUI

// MARK: - DraggableSheetModifier

/// ViewModifier that overlays a `DraggableSheetView` on the modified view.
///
/// Prefer using the `.draggableSheet(...)` extension instead of this directly.
struct DraggableSheetModifier<SheetContent: View>: ViewModifier {

    @Binding var position: SheetPosition
    let positions: [SheetPosition]
    let configuration: SheetConfiguration
    let accessibilityLabel: String
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content.overlay {
            DraggableSheetView(
                position: $position,
                positions: positions,
                configuration: configuration,
                accessibilityLabel: accessibilityLabel,
                content: sheetContent
            )
        }
    }
}

// MARK: - View Extension

public extension View {

    /// Attaches a draggable bottom sheet to this view.
    ///
    /// ```swift
    /// @State private var sheetPosition: SheetPosition = .small
    ///
    /// Map()
    ///     .draggableSheet(position: $sheetPosition) {
    ///         PlaceDetails()
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - position: Binding to the current sheet position.
    ///   - positions: Allowed snap positions (stored once, won't cause re-renders).
    ///   - configuration: Styling and behavior options.
    ///   - accessibilityLabel: VoiceOver label for the drag handle.
    ///   - content: The sheet's content view.
    func draggableSheet<SheetContent: View>(
        position: Binding<SheetPosition>,
        positions: [SheetPosition] = SheetPosition.defaults,
        configuration: SheetConfiguration = SheetConfiguration(),
        accessibilityLabel: String = "Draggable Sheet",
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(
            DraggableSheetModifier(
                position: position,
                positions: positions,
                configuration: configuration,
                accessibilityLabel: accessibilityLabel,
                sheetContent: content
            )
        )
    }
}
