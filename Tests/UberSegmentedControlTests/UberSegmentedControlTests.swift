import XCTest
@testable import UberSegmentedControl

final class UberSegmentedControlTests: XCTestCase {
    var singleTextSC: UberSegmentedControl! = nil
    var multiTextSC: UberSegmentedControl! = nil

    override func setUp() {
        singleTextSC = UberSegmentedControl(items: ["Left", "Right"])
        multiTextSC = UberSegmentedControl(items: ["Left", "Right"], allowsMultipleSelection: true)
    }

    override func tearDown() {
        singleTextSC = nil
        multiTextSC = nil
    }

    func testNumberOfSegments() {
        // Control should have exactly 2 segments.
        XCTAssertEqual(singleTextSC.numberOfSegments, 2)
    }

    func testInsertingAndRemovingSegments() {
        singleTextSC.insertSegment(withTitle: "Up", at: 2, animated: false)
        singleTextSC.insertSegment(withTitle: "Down", at: 3, animated: false)

        // Control should have exactly 4 segments.
        XCTAssertEqual(singleTextSC.numberOfSegments, 4)

        // Segment 2 should contain title "Up".
        XCTAssertEqual(singleTextSC.titleForSegment(at: 2), "Up")
        // Segment 3 should contain title "Down".
        XCTAssertEqual(singleTextSC.titleForSegment(at: 3), "Down")

        // Non-animated removals
        singleTextSC.removeSegment(at: 3, animated: false)
        singleTextSC.removeSegment(at: 2, animated: false)

        // Control should have exactly 2 segments.
        XCTAssertEqual(self.singleTextSC.numberOfSegments, 2)

        // Segment 2 should contain no title.
        XCTAssertNil(self.singleTextSC.titleForSegment(at: 2))
        // Segment 3 should contain no title.
        XCTAssertNil(self.singleTextSC.titleForSegment(at: 3))

        // Animated removal
        singleTextSC.removeSegment(at: 1, animated: true)
        singleTextSC.removeSegment(at: 0, animated: true)

        // Wait for animation to complete...
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Control should have exactly 0 segments.
            XCTAssertEqual(self.singleTextSC.numberOfSegments, 0)
            // Segment 0 should contain no title.
            XCTAssertNil(self.singleTextSC.titleForSegment(at: 0))
            // Segment 1 should contain no title.
            XCTAssertNil(self.singleTextSC.titleForSegment(at: 1))
        }
    }

    func testTitles() {
        XCTAssertEqual(singleTextSC.titleForSegment(at: 0), "Left")
        XCTAssertEqual(singleTextSC.titleForSegment(at: 1), "Right")
        XCTAssertNil(singleTextSC.titleForSegment(at: 2))

        singleTextSC.setTitle(nil, forSegmentAt: 0)
        // Segment 0 should not contain a title.
        XCTAssertNil(singleTextSC.titleForSegment(at: 0))

        singleTextSC.setTitle("Up", forSegmentAt: 0)
        // Segment 0 should contain title "Up".
        XCTAssertEqual(singleTextSC.titleForSegment(at: 0), "Up")
    }

    func testImages() {
        // Segments 0, 1, and 2 should not contain images.
        XCTAssertNil(singleTextSC.imageForSegment(at: 0))
        XCTAssertNil(singleTextSC.imageForSegment(at: 1))
        XCTAssertNil(singleTextSC.imageForSegment(at: 2))

        // Placeholder image
        let image = placeholderImage()

        singleTextSC.setImage(image, forSegmentAt: 0)
        // Segment 0 should contain image `image`.
        XCTAssertEqual(singleTextSC.imageForSegment(at: 0), image)

        singleTextSC.setImage(nil, forSegmentAt: 0)
        // Segment 0 should not contain an image.
        XCTAssertNil(singleTextSC.imageForSegment(at: 0))
    }

    func testSelectedIndexesSingle() {
        // There should be no selection.
        XCTAssertTrue(singleTextSC.selectedSegmentIndexes.isEmpty)

        singleTextSC.selectedSegmentIndexes = IndexSet([0])
        // Index 0 should be selected.
        XCTAssertEqual(singleTextSC.selectedSegmentIndexes, IndexSet([0]))

        singleTextSC.selectedSegmentIndexes = IndexSet([0, 1])
        // Only the smallest index should be selected.
        XCTAssertEqual(singleTextSC.selectedSegmentIndexes, IndexSet([0]))

        singleTextSC.selectedSegmentIndexes = IndexSet([1])
        // Index 1 should be selected.
        XCTAssertEqual(singleTextSC.selectedSegmentIndexes, IndexSet([1]))

        singleTextSC.selectedSegmentIndexes = IndexSet([1, 0])
        // Only the smallest index should be selected.
        XCTAssertEqual(singleTextSC.selectedSegmentIndexes, IndexSet([0]))

        singleTextSC.selectedSegmentIndexes = IndexSet([1, 0, 1, 0])
        // Duplicated indices should be ignored & only smallest index should be selected.
        XCTAssertEqual(singleTextSC.selectedSegmentIndexes, IndexSet([0]))
    }

    func testSelectedIndexesMulti() {
        // There should be no selection.
        XCTAssertTrue(multiTextSC.selectedSegmentIndexes.isEmpty)

        multiTextSC.selectedSegmentIndexes = IndexSet([0])
        // Index 0 should be selected.
        XCTAssertEqual(multiTextSC.selectedSegmentIndexes, IndexSet([0]))

        multiTextSC.selectedSegmentIndexes = IndexSet([0, 1])
        // Both index 0 and 1 should be selected.
        XCTAssertEqual(multiTextSC.selectedSegmentIndexes, IndexSet([0, 1]))

        multiTextSC.selectedSegmentIndexes = IndexSet([1])
        // Index 1 should be selected.
        XCTAssertEqual(multiTextSC.selectedSegmentIndexes, IndexSet([1]))

        multiTextSC.selectedSegmentIndexes = IndexSet([1, 0])
        // Both index 0 and 1 should be selected.
        XCTAssertEqual(multiTextSC.selectedSegmentIndexes, IndexSet([0, 1]))

        multiTextSC.selectedSegmentIndexes = IndexSet([1, 0, 1, 0])
        // Duplicated indices should be ignored.
        XCTAssertEqual(multiTextSC.selectedSegmentIndexes, IndexSet([0, 1]))
    }
}

private extension UberSegmentedControlTests {
    func placeholderImage() -> UIImage {
        return UIImage(ciImage: CIImage(color: CIColor(red: 1, green: 1, blue: 1)))
    }
}
