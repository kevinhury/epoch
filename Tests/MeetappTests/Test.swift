import XCTest
@testable import Meetapp

class PostTest: XCTestCase {
    
    func testExample() {
        let post = Post(content: "hello")
        XCTAssertEqual(post.content, "hello")
    }
    
    static var allTests: [(String, (PostTest) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
