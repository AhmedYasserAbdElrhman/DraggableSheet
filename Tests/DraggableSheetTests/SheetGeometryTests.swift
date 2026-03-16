import Testing
@testable import DraggableSheet

@Suite("SheetGeometry")
struct SheetGeometryTests {

    private let small = SheetPosition.small    // 180pt
    private let medium = SheetPosition.medium  // 500pt
    private let full = SheetPosition.full      // 100%

    private var geo: SheetGeometry {
        SheetGeometry(positions: [medium, full, small], containerHeight: 1000)
    }

    // MARK: - Sorting

    @Test("sorted returns positions in ascending height order")
    func sortedOrder() {
        let sorted = geo.sorted
        #expect(sorted.map(\.id) == ["small", "medium", "full"])
    }

    // MARK: - Index Lookup

    @Test("index returns correct position for each")
    func indexLookup() {
        #expect(geo.index(of: small) == 0)
        #expect(geo.index(of: medium) == 1)
        #expect(geo.index(of: full) == 2)
    }

    @Test("index returns 0 for unknown position")
    func indexUnknown() {
        let unknown = SheetPosition(name: "unknown", mode: .absolute(999))
        #expect(geo.index(of: unknown) == 0)
    }

    // MARK: - Bounds

    @Test("lowerBound returns own height at bottom position")
    func lowerBoundAtBottom() {
        let lower = geo.lowerBound(for: small)
        #expect(lower == 180) // small is the lowest, returns its own height
    }

    @Test("lowerBound returns previous position height")
    func lowerBoundMiddle() {
        let lower = geo.lowerBound(for: medium)
        #expect(lower == 180) // small is below medium
    }

    @Test("upperBound returns own height at top position")
    func upperBoundAtTop() {
        let upper = geo.upperBound(for: full)
        #expect(upper == 1000) // full is the highest, returns its own height
    }

    @Test("upperBound returns next position height")
    func upperBoundMiddle() {
        let upper = geo.upperBound(for: medium)
        #expect(upper == 1000) // full is above medium
    }

    // MARK: - Drag Height

    @Test("dragHeight with zero offset returns base height")
    func dragHeightNoOffset() {
        #expect(geo.dragHeight(for: medium, offset: 0) == 500)
    }

    @Test("dragHeight clamps to lower bound when dragging down")
    func dragHeightClampDown() {
        // Dragging down (positive offset) reduces height, clamped to small (180)
        #expect(geo.dragHeight(for: medium, offset: 500) == 180)
    }

    @Test("dragHeight clamps to upper bound when dragging up")
    func dragHeightClampUp() {
        // Dragging up (negative offset) increases height, clamped to full (1000)
        #expect(geo.dragHeight(for: medium, offset: -700) == 1000)
    }

    @Test("dragHeight tracks offset within bounds")
    func dragHeightWithinBounds() {
        // medium (500) - 100 offset = 400, which is between small (180) and full (1000)
        #expect(geo.dragHeight(for: medium, offset: 100) == 400)
    }

    // MARK: - Snap Target

    @Test("snap target moves down on decisive swipe down")
    func snapDown() {
        let target = geo.snapTarget(
            from: medium,
            translation: 60,
            predictedEndTranslation: 120,
            dragOffset: 60,
            threshold: 50
        )
        #expect(target == small)
    }

    @Test("snap target moves up on decisive swipe up")
    func snapUp() {
        let target = geo.snapTarget(
            from: medium,
            translation: -60,
            predictedEndTranslation: -120,
            dragOffset: -60,
            threshold: 50
        )
        #expect(target == full)
    }

    @Test("snap target stays at bottom when swiping down at lowest")
    func snapDownAtBottom() {
        let target = geo.snapTarget(
            from: small,
            translation: 60,
            predictedEndTranslation: 120,
            dragOffset: 60,
            threshold: 50
        )
        #expect(target == small) // already at bottom, snaps back
    }

    @Test("snap target snaps to closest when under threshold")
    func snapToClosest() {
        let target = geo.snapTarget(
            from: medium,
            translation: 20,
            predictedEndTranslation: 30,
            dragOffset: 20,
            threshold: 50
        )
        #expect(target == medium) // small movement, stays at medium
    }

    @Test("fast flick with small translation still snaps via predicted translation")
    func velocityBasedSnap() {
        // Small actual translation but high predicted (fast flick)
        let target = geo.snapTarget(
            from: medium,
            translation: -20,
            predictedEndTranslation: -200,
            dragOffset: -20,
            threshold: 50
        )
        #expect(target == full) // predicted exceeds threshold
    }

    // MARK: - Validation

    @Test("validated returns same position when it exists")
    func validatedExisting() {
        #expect(geo.validated(medium) == medium)
    }

    @Test("validated returns closest position for unknown")
    func validatedUnknown() {
        let unknown = SheetPosition(name: "near-medium", mode: .absolute(480))
        let validated = geo.validated(unknown)
        #expect(validated == medium) // 480 is closest to 500 (medium)
    }
}
