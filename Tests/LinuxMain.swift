import XCTest  
@testable import EpochAuthTests
@testable import MeetappTests

XCTMain([  
    testCase(DummyTests.allTests),
    testCase(PostTest.allTests),
])
