@testable import ExamplePackage
import XCTest

final class Subtests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ExamplePackage.exampleText(), "Package: example text Subpackage")
    }
}
