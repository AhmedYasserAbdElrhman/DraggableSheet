<h1 align="center">🗂️ DraggableSheet</h1>

<p align="center">
  <strong>A polished, gesture-driven draggable bottom sheet for SwiftUI.</strong><br>
  Snap between positions · Full-view drag · ScrollView coordination · Swift 6 ready
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/swift-6.0-orange?style=flat-square" alt="Swift">
  <img src="https://img.shields.io/badge/SPM-compatible-brightgreen?style=flat-square" alt="SPM">
  <img src="https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square" alt="License">
</p>

---

## 🎬 Demo

<p align="center">
  <img src="https://s13.gifyu.com/images/bmlNi.gif" width="300" alt="DraggableSheet Demo">
</p>

---

## ✨ Features

| | Feature |
|---|---|
| 📐 | **Flexible Positions** — snap between any number of positions (absolute, percentage, or dynamic) |
| 🖐️ | **Full-View Drag** — drag anywhere on the sheet, not just the handle |
| 📜 | **ScrollView Coordination** — smart drag ↔ scroll handoff via `SheetScrollView` |
| ⚡ | **Velocity-Based Snapping** — responsive flick gestures that feel native |
| 🌗 | **Dimming Overlay** — optional background dim that scales with sheet height |
| 🎨 | **Fully Customizable** — corner radius, colors, handle, shadow, animation, and more |
| 🧩 | **Two APIs** — `.draggableSheet()` modifier or direct `DraggableSheetView` |
| 🤖 | **Automation Ready** — accessibility identifiers for Appium & UI testing |
| 🔒 | **Swift 6 Concurrency** — `@MainActor` isolated, `Sendable` safe |

---

## 📦 Installation

### Swift Package Manager

Add it through **Xcode**:

1. **File → Add Package Dependencies...**
2. Paste the URL:
   ```
   https://github.com/AhmedYasserAbdElrhman/DraggableSheet.git
   ```
3. Version rule: **Up to Next Major** from `0.0.1`
4. Click **Add Package** 🎉

Or in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AhmedYasserAbdElrhman/DraggableSheet.git", from: "0.0.1")
]
```

```swift
.target(
    name: "YourApp",
    dependencies: ["DraggableSheet"]
)
```

---

## 🚀 Usage

### 1️⃣ ViewModifier API *(Recommended)*

The simplest way — attach a sheet to any view:

```swift
import DraggableSheet

struct ContentView: View {
    @State private var position: SheetPosition = .small

    var body: some View {
        Map()
            .draggableSheet(position: $position) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Place Details")
                        .font(.title2.bold())
                    Text("Drag anywhere on this sheet to resize it.")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
            }
    }
}
```

### 2️⃣ Direct View API

For more control over placement:

```swift
DraggableSheetView(
    position: $position,
    positions: [.small, .medium, .full]
) {
    Text("Sheet Content")
        .padding()
}
```

### 3️⃣ ScrollView Integration

Drop in `SheetScrollView` and the sheet handles everything — collapses when scrolled to top, scrolls content otherwise:

```swift
.draggableSheet(position: $position) {
    SheetScrollView {
        LazyVStack(spacing: 0) {
            ForEach(items) { item in
                ItemRow(item: item)
            }
        }
    }
}
```

### 4️⃣ Custom Positions

Use the built-ins or create your own:

```swift
// 📏 Built-in positions
.small    // 180pt fixed
.medium   // 500pt fixed
.large    // 80% of container
.full     // 100% of container

// 🛠️ Custom positions
let compact  = SheetPosition(name: "compact", mode: .absolute(120))
let half     = SheetPosition(name: "half", mode: .percentage(0.5))
let computed = SheetPosition(name: "dynamic", mode: .dynamic { UIScreen.main.bounds.height * 0.6 })
```

```swift
.draggableSheet(
    position: $position,
    positions: [compact, half, .full]
) {
    // ...
}
```

---

## ⚙️ Configuration

Fine-tune everything through `SheetConfiguration`:

```swift
let config = SheetConfiguration(
    cornerRadius: 24,
    backgroundColor: Color(.systemBackground),
    shadowRadius: 8,
    showHandle: true,
    handleColor: .gray.opacity(0.4),
    handleSize: CGSize(width: 40, height: 5),
    maxDimmingOpacity: 0.3,
    dragThreshold: 50,
    animation: .interactiveSpring(response: 0.4, dampingFraction: 0.8)
)

.draggableSheet(position: $position, configuration: config) {
    // ...
}
```

### 🎛️ Configuration Options

| Parameter | Type | Default | Description |
|:----------|:-----|:--------|:------------|
| `cornerRadius` | `CGFloat` | `16` | Top corner radius of the sheet |
| `backgroundColor` | `Color` | `.white` | Sheet surface color |
| `shadowRadius` | `CGFloat` | `4` | Shadow behind the sheet |
| `showHandle` | `Bool` | `true` | Show/hide the drag handle indicator |
| `handleColor` | `Color` | `.gray.opacity(0.5)` | Drag handle capsule color |
| `handleSize` | `CGSize` | `40 × 5` | Drag handle capsule dimensions |
| `maxDimmingOpacity` | `Double` | `0` | Max dimming overlay opacity (`0` = disabled) |
| `dragThreshold` | `CGFloat` | `50` | Min drag distance to trigger a position snap |
| `animation` | `Animation` | `.interactiveSpring(...)` | Spring animation for snapping |

### 📐 Position Height Modes

| Mode | Example | Description |
|:-----|:--------|:------------|
| `.absolute(CGFloat)` | `.absolute(200)` | Fixed height in points |
| `.percentage(CGFloat)` | `.percentage(0.5)` | Fraction of container height (0.0–1.0) |
| `.dynamic(() -> CGFloat)` | `.dynamic { compute() }` | Height computed by a closure at layout time |

---

## 🏗️ Architecture

```
Sources/DraggableSheet/
├── 📁 Models/
│   ├── SheetPosition.swift          # Snap position model with height modes
│   └── SheetConfiguration.swift     # Styling & behavior options
├── 📁 Core/
│   ├── DraggableSheetView.swift     # Main sheet view with gesture handling
│   └── SheetGeometry.swift          # Layout math (snap targets, bounds, clamping)
├── 📁 Components/
│   └── DragHandleView.swift         # Capsule drag indicator
├── 📁 Modifiers/
│   └── DraggableSheetModifier.swift # .draggableSheet() ViewModifier
├── 📁 Utilities/
│   └── ScrollOffsetTracker.swift    # SheetScrollView & scroll state tracking
└── DraggableSheet.swift             # Public API re-exports
```

---

## 📋 Requirements

| | Minimum |
|---|---|
| 📱 **iOS** | 16.0+ |
| 🐦 **Swift** | 6.0+ |
| 🛠️ **Xcode** | 16.0+ |

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. **Fork** the repository
2. **Branch** — `git checkout -b feature/your-feature`
3. **Commit** — `git commit -m 'Add your feature'`
4. **Push** — `git push origin feature/your-feature`
5. **Open a Pull Request** 🚀

Please follow the existing code style and include appropriate documentation.

---

## 📄 License

DraggableSheet is available under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ for the SwiftUI community
</p>
