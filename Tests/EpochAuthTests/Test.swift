import XCTest
@testable import EpochAuth

class DummyTest: XCTestCase {
    
    func testExample() {
        let mispar = 42
        XCTAssertTrue(mispar == 42)
    }
    
    
    static var allTests: [(String, (DummyTest) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
