import SwiftUI
import DraggableSheet

// MARK: - Content View

struct ContentView: View {

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ModifierDemoView()
                .tabItem {
                    Label("Modifier", systemImage: "slider.horizontal.3")
                }
                .tag(0)

            DirectDemoView()
                .tabItem {
                    Label("Direct", systemImage: "square.stack.3d.up")
                }
                .tag(1)

            ScrollDemoView()
                .tabItem {
                    Label("Scroll", systemImage: "scroll")
                }
                .tag(2)
        }
    }
}

// MARK: - Tab 1: ViewModifier API Demo

struct ModifierDemoView: View {

    @State private var sheetPosition: SheetPosition = .small

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.15), .purple.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Current: **\(sheetPosition.name)**")
                        .font(.title3)

                    HStack(spacing: 12) {
                        positionButton("Small", position: .small)
                        positionButton("Medium", position: .medium)
                        positionButton("Full", position: .full)
                    }

                    Spacer()
                }
                .padding(.top, 24)
            }
            .navigationTitle("Modifier API")
            .navigationBarTitleDisplayMode(.inline)
            .draggableSheet(position: $sheetPosition) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sheet Content")
                        .font(.title2.bold())

                    Text("This sheet is attached using the `.draggableSheet()` view modifier. Drag anywhere on the sheet to move it.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)

                    Divider()

                    ForEach(0..<5) { i in
                        Label("Item \(i + 1)", systemImage: "star.fill")
                            .padding(.vertical, 4)
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }

    @ViewBuilder
    private func positionButton(_ title: String, position: SheetPosition) -> some View {
        Button {
            withAnimation(.interactiveSpring()) {
                sheetPosition = position
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    sheetPosition == position
                        ? Color.blue
                        : Color(.systemGray5)
                )
                .foregroundColor(sheetPosition == position ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Tab 2: Direct View Usage

struct DirectDemoView: View {

    @State private var sheetPosition: SheetPosition = .medium

    private let customPositions: [SheetPosition] = [
        SheetPosition(name: "peek", mode: .absolute(120)),
        SheetPosition(name: "half", mode: .percentage(0.5)),
        SheetPosition(name: "expanded", mode: .percentage(0.85)),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Current: **\(sheetPosition.name)**")
                        .font(.title3)

                    Text("Using **custom positions**:\npeek (120pt) · half (50%) · expanded (85%)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Spacer()
                }
                .padding(.top, 24)

                DraggableSheetView(
                    position: $sheetPosition,
                    positions: customPositions,
                    configuration: SheetConfiguration(
                        cornerRadius: 24,
                        backgroundColor: Color(.secondarySystemBackground),
                        shadowRadius: 8,
                        handleColor: .orange.opacity(0.6),
                        handleSize: CGSize(width: 50, height: 6)
                    )
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Custom Sheet")
                            .font(.title2.bold())

                        Text("This uses `DraggableSheetView` directly with custom positions and a custom configuration (orange handle, 24pt corners).")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Divider()

                        ForEach(0..<8) { i in
                            HStack {
                                Circle()
                                    .fill(.orange.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "\(i + 1).circle.fill")
                                            .foregroundStyle(.orange)
                                    )

                                VStack(alignment: .leading) {
                                    Text("Custom Item \(i + 1)")
                                        .font(.body.weight(.medium))
                                    Text("Description text")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 2)
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Direct View")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Tab 3: ScrollView Integration

struct ScrollDemoView: View {

    @State private var sheetPosition: SheetPosition = .medium

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Current: **\(sheetPosition.name)**")
                        .font(.title3)

                    Text("Sheet with **SheetScrollView** inside.\nDrag the sheet to resize, scroll inside the content.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Spacer()
                }
                .padding(.top, 24)

                DraggableSheetView(
                    position: $sheetPosition,
                    positions: [.small, .medium, .full],
                    configuration: SheetConfiguration(
                        cornerRadius: 20,
                        backgroundColor: Color(.systemBackground),
                        shadowRadius: 6
                    )
                ) {
                    SheetScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<40, id: \.self) { i in
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(rowColor(for: i).opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text("\(i + 1)")
                                                .font(.caption.bold())
                                                .foregroundStyle(rowColor(for: i))
                                        )

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Scrollable Item \(i + 1)")
                                            .font(.body.weight(.medium))
                                        Text("Scroll works when sheet is fully expanded")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.quaternary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)

                                Divider().padding(.leading, 64)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Scroll Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func rowColor(for index: Int) -> Color {
        let colors: [Color] = [.blue, .purple, .green, .orange, .red, .teal]
        return colors[index % colors.count]
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
