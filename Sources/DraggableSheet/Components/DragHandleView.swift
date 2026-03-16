import SwiftUI

// MARK: - DragHandleView

/// The capsule indicator at the top of the sheet that visually communicates draggability.
struct DragHandleView: View {

    let configuration: SheetConfiguration
    let accessibilityLabel: String

    var body: some View {
        Capsule()
            .fill(configuration.handleColor)
            .frame(
                width: configuration.handleSize.width,
                height: configuration.handleSize.height
            )
            .padding(.vertical, 10)
            .accessibilityLabel(accessibilityLabel)
    }
}
