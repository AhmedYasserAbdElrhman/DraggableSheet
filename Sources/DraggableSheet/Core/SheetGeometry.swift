import SwiftUI

// MARK: - SheetGeometry

/// Pure value type that encapsulates all sheet layout math.
///
/// Extracted from the view body to avoid re-computing on every render
/// and to satisfy Single-Responsibility.
struct SheetGeometry {

    let positions: [SheetPosition]
    let containerHeight: CGFloat

    /// Positions sorted by resolved height (ascending), computed once at init.
    let sorted: [SheetPosition]

    init(positions: [SheetPosition], containerHeight: CGFloat) {
        self.positions = positions
        self.containerHeight = containerHeight
        self.sorted = positions.sorted {
            $0.height(in: containerHeight) < $1.height(in: containerHeight)
        }
    }

    // MARK: - Index Lookup

    /// Index of the given position within `sorted`.
    func index(of position: SheetPosition) -> Int {
        sorted.firstIndex(of: position) ?? 0
    }

    // MARK: - Neighbour Heights

    /// The height of the position one step below `position`, or its own height if already at the bottom.
    func lowerBound(for position: SheetPosition) -> CGFloat {
        let idx = index(of: position)
        guard idx > 0 else { return position.height(in: containerHeight) }
        return sorted[idx - 1].height(in: containerHeight)
    }

    /// The height of the position one step above `position`, or its own height if already at the top.
    func upperBound(for position: SheetPosition) -> CGFloat {
        let idx = index(of: position)
        guard idx < sorted.count - 1 else { return position.height(in: containerHeight) }
        return sorted[idx + 1].height(in: containerHeight)
    }

    // MARK: - Dynamic Height During Drag

    /// Returns the sheet height clamped between the adjacent positions while dragging.
    func dragHeight(for position: SheetPosition, offset: CGFloat) -> CGFloat {
        let base = position.height(in: containerHeight)
        let lower = lowerBound(for: position)
        let upper = upperBound(for: position)
        return min(max(base - offset, lower), upper)
    }

    // MARK: - Snap Target

    /// Determines which position to snap to after a drag ends.
    ///
    /// - If the drag exceeds `threshold` points, snap to the next/previous position.
    /// - Otherwise, snap to the nearest position by height proximity.
    func snapTarget(
        from current: SheetPosition,
        translation: CGFloat,
        predictedEndTranslation: CGFloat,
        dragOffset: CGFloat,
        threshold: CGFloat
    ) -> SheetPosition {
        let sortedPositions = sorted
        let idx = index(of: current)

        // Use predicted end translation for decisive swipe detection (accounts for velocity)
        if predictedEndTranslation > threshold, idx > 0 {
            return sortedPositions[idx - 1]
        }

        // Decisive swipe up
        if predictedEndTranslation < -threshold, idx < sortedPositions.count - 1 {
            return sortedPositions[idx + 1]
        }

        // No decisive swipe — snap to closest by current visual position
        let currentY = containerHeight - current.height(in: containerHeight) + dragOffset
        var closest = current
        var closestDist: CGFloat = .greatestFiniteMagnitude

        for pos in sortedPositions {
            let posY = containerHeight - pos.height(in: containerHeight)
            let dist = abs(currentY - posY)
            if dist < closestDist {
                closestDist = dist
                closest = pos
            }
        }

        return closest
    }

    // MARK: - Validation

    /// Returns `current` if it exists in `positions`, otherwise the closest position by height.
    func validated(_ current: SheetPosition) -> SheetPosition {
        if positions.contains(current) { return current }

        let h = current.height(in: containerHeight)
        return sorted.min(by: {
            abs($0.height(in: containerHeight) - h) < abs($1.height(in: containerHeight) - h)
        }) ?? sorted.first ?? current
    }
}
