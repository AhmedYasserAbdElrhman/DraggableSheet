import SwiftUI

// MARK: - Basic Sheet Preview

#Preview("Basic Sheet") {
    struct PreviewContainer: View {
        @State private var position: SheetPosition = .medium

        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    Text("Current: \(position.name)")
                        .font(.headline)
                        .padding()

                    HStack(spacing: 12) {
                        ForEach(
                            [SheetPosition.small, .medium, .full],
                            id: \.id
                        ) { pos in
                            Button(pos.name.capitalized) {
                                withAnimation(.interactiveSpring()) {
                                    position = pos
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    Spacer()
                }

                DraggableSheetView(
                    position: $position,
                    positions: [.small, .medium, .full]
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sheet Content")
                            .font(.title2.bold())
                        Text("Drag anywhere on this sheet to move it between small, medium, and full positions.")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
    return PreviewContainer()
}

// MARK: - ScrollView Preview

#Preview("With ScrollView") {
    struct ScrollPreview: View {
        @State private var position: SheetPosition = .medium

        var body: some View {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()

                DraggableSheetView(
                    position: $position,
                    positions: [.small, .medium, .full],
                    configuration: SheetConfiguration(
                        cornerRadius: 24,
                        backgroundColor: Color(.systemBackground),
                        shadowRadius: 8,
                        handleColor: .gray.opacity(0.4)
                    )
                ) {
                    SheetScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<30, id: \.self) { i in
                                HStack {
                                    Circle()
                                        .fill(.blue.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay(Text("\(i)").font(.caption))
                                    VStack(alignment: .leading) {
                                        Text("Item \(i)")
                                            .font(.body.weight(.medium))
                                        Text("Subtitle text")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }
    return ScrollPreview()
}

// MARK: - Modifier API Preview

#Preview("Modifier API") {
    struct ModifierPreview: View {
        @State private var position: SheetPosition = .small

        var body: some View {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack {
                    Text("Background Content")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.top, 60)
            }
            .draggableSheet(position: $position) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Modifier API")
                        .font(.title2.bold())
                    Text("Attached via .draggableSheet() modifier.")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
            }
        }
    }
    return ModifierPreview()
}
