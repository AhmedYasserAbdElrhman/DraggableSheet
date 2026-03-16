import SwiftUI

// MARK: - DraggableSheetView

/// A draggable bottom sheet that snaps between configurable positions.
///
/// Supports full-view dragging with `ScrollView` coordination via `SheetScrollView`.
///
/// ```swift
/// @State private var position: SheetPosition = .medium
///
/// DraggableSheetView(
///     position: $position,
///     positions: [.small, .medium, .full]
/// ) {
///     Text("Sheet Content")
/// }
/// ```
public struct DraggableSheetView<Content: View>: View {

    // MARK: - State

    @Binding var position: SheetPosition
    @State private var dragOffset: CGFloat = 0
    @State private var isDraggingSheet: Bool = false
    /// Reference type shared with `SheetScrollView` via environment.
    /// Stores scroll offset, scroll-content presence, and gesture decision flag.
    @State private var scrollState = SheetScrollState()

    // MARK: - Config (stored once, no re-render)

    let positions: [SheetPosition]
    let configuration: SheetConfiguration
    let accessibilityLabel: String
    let content: () -> Content

    // MARK: - Init

    public init(
        position: Binding<SheetPosition>,
        positions: [SheetPosition] = SheetPosition.defaults,
        configuration: SheetConfiguration = SheetConfiguration(),
        accessibilityLabel: String = "Draggable Sheet",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._position = position
        self.positions = positions
        self.configuration = configuration
        self.accessibilityLabel = accessibilityLabel
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        // Outer proxy captures safe area BEFORE it's consumed.
        // Inner proxy gets the full height including bottom safe area.
        GeometryReader { safeAreaProxy in
            let bottomInset = safeAreaProxy.safeAreaInsets.bottom

            GeometryReader { outer in
                let containerHeight = outer.size.height
                let geo = SheetGeometry(
                    positions: positions,
                    containerHeight: containerHeight
                )
                let validatedPosition = geo.validated(position)
                let dynamicHeight = geo.dragHeight(
                    for: validatedPosition,
                    offset: dragOffset
                )
                let topOffset = containerHeight - dynamicHeight

                ZStack(alignment: .top) {
                    // Dimming overlay — optional, fades in as sheet grows
                    Color.black.opacity(dimmingOpacity(dynamicHeight, in: containerHeight))
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    VStack(spacing: 0) {
                        if configuration.showHandle {
                            DragHandleView(
                                configuration: configuration,
                                accessibilityLabel: accessibilityLabel
                            )
                        }

                        content()
                            .scrollDisabled(isDraggingSheet)
                            .padding(.bottom, bottomInset)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .frame(width: outer.size.width, height: dynamicHeight, alignment: .top)
                    .background(configuration.backgroundColor)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: configuration.cornerRadius,
                            topTrailingRadius: configuration.cornerRadius
                        )
                    )
                    .shadow(radius: configuration.shadowRadius)
                    .offset(y: topOffset)
                    .environment(\.sheetScrollState, scrollState)
                    .simultaneousGesture(sheetDragGesture(geo: geo))
                }
                .onAppear {
                    // Validate position on first layout
                    let validated = geo.validated(position)
                    if validated != position {
                        position = validated
                    }
                }
                .onChange(of: positions) { _ in
                    // Re-validate when positions change
                    let validated = geo.validated(position)
                    if validated != position {
                        position = validated
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    // MARK: - Gesture

    private func sheetDragGesture(geo: SheetGeometry) -> some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                let translation = value.translation.height

                // Decide once per gesture session: sheet drag or scroll?
                if !scrollState.gestureDecided {
                    scrollState.gestureDecided = true
                    let isAtScrollTop = scrollState.offset <= 0
                    let isDraggingDown = translation > 0
                    let isDraggingUp = translation < 0
                    let isAtMaxPosition = geo.index(of: position) == geo.sorted.count - 1


                    if isDraggingDown && isAtScrollTop {
                        // Scroll is at top, dragging down → collapse sheet
                        // (nothing above to scroll to, so move the sheet instead)
                        isDraggingSheet = true
                    } else if isDraggingUp && !isAtMaxPosition {
                        // Sheet not fully expanded, dragging up → expand sheet
                        isDraggingSheet = true
                    } else {
                        // At max position dragging up → let scroll handle it
                        // Or scrolled down and dragging down → let scroll handle it
                        isDraggingSheet = false
                    }
                }

                if isDraggingSheet {
                    dragOffset = translation
                }
            }
            .onEnded { value in
                if isDraggingSheet {
                    let target = geo.snapTarget(
                        from: position,
                        translation: value.translation.height,
                        predictedEndTranslation: value.predictedEndTranslation.height,
                        dragOffset: dragOffset,
                        threshold: configuration.dragThreshold
                    )
                    withAnimation(configuration.animation) {
                        position = target
                        dragOffset = 0
                    }
                }

                // Reset for next gesture
                isDraggingSheet = false
                scrollState.gestureDecided = false
            }
    }

    // MARK: - Helpers

    /// Subtle dimming behind the sheet, proportional to how expanded it is.
    private func dimmingOpacity(_ currentHeight: CGFloat, in containerHeight: CGFloat) -> Double {
        guard configuration.maxDimmingOpacity > 0, containerHeight > 0 else { return 0 }
        let progress = currentHeight / containerHeight
        return Double(progress) * configuration.maxDimmingOpacity
    }
}
