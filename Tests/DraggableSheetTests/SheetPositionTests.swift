import Testing
import Foundation
@testable import DraggableSheet

@Suite("SheetPosition")
struct SheetPositionTests {

    // MARK: - Height Resolution

    @Test("absolute height is clamped to container")
    func absoluteHeight() {
        let pos = SheetPosition(name: "test", mode: .absolute(300))
        #expect(pos.height(in: 800) == 300)
        #expect(pos.height(in: 200) == 200) // clamped
    }

    @Test("percentage height resolves correctly")
    func percentageHeight() {
        let pos = SheetPosition(name: "half", mode: .percentage(0.5))
        #expect(pos.height(in: 1000) == 500)
        #expect(pos.height(in: 400) == 200)
    }

    @Test("percentage above 1.0 is clamped")
    func percentageClamp() {
        let pos = SheetPosition(name: "over", mode: .percentage(1.5))
        #expect(pos.height(in: 800) == 800) // clamped to container
    }

    @Test("dynamic height uses closure result")
    func dynamicHeight() {
        let pos = SheetPosition(name: "dynamic", mode: .dynamic { 250 })
        #expect(pos.height(in: 800) == 250)
        #expect(pos.height(in: 100) == 100) // clamped
    }

    // MARK: - Identity

    @Test("equality is based on id, not mode")
    func equalityById() {
        let a = SheetPosition(name: "same", mode: .absolute(100))
        let b = SheetPosition(name: "same", mode: .absolute(999))
        #expect(a == b)
    }

    @Test("different names are not equal")
    func inequalityByName() {
        let a = SheetPosition(name: "a", mode: .absolute(100))
        let b = SheetPosition(name: "b", mode: .absolute(100))
        #expect(a != b)
    }

    // MARK: - Built-in Positions

    @Test("built-in positions resolve expected heights")
    func builtInHeights() {
        let container: CGFloat = 1000
        #expect(SheetPosition.small.height(in: container) == 180)
        #expect(SheetPosition.medium.height(in: container) == 500)
        #expect(SheetPosition.large.height(in: container) == 800)
        #expect(SheetPosition.full.height(in: container) == 1000)
    }
}
