import SwiftUI

/// A drop-in ScrollView replacement that reports its content offset to the sheet.
///
/// Use this inside your sheet content when you need scroll + drag coordination:
/// ```swift
/// .draggableSheet(position: $pos) {
///     SheetScrollView {
///         ForEach(items) { item in
///             ItemRow(item)
///         }
///     }
/// }
/// ```
public struct SheetScrollView<Content: View>: View {

    @Environment(\.sheetScrollState) private var scrollState

    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let content: () -> Content

    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content
    }

    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content()
                .background(
                    GeometryReader { inner in
                        let offset = -inner.frame(in: .named(sheetScrollCoordinateSpace)).origin.y
                        Color.clear
                            .onAppear {
                                scrollState?.offset = offset
                                scrollState?.hasScrollContent = true
                            }
                            .onChange(of: offset) { newValue in
                                scrollState?.offset = newValue
                            }
                    }
                )
        }
        .coordinateSpace(name: sheetScrollCoordinateSpace)
    }
}
