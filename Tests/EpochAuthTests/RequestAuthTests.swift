//
//  RequestAuthTests.swift
//  Epoch
//
//  Created by Kevin Hury on 20/10/2016.
//
//

import XCTest
@testable import HTTP
@testable import EpochAuth

class RequestAuthTests: XCTestCase {
    
    func testBaseURL() {
        let uri = "https://www.google.co.il/search?q=epoch&biw=1164&bih=576&source=lnms&sa=X&ved=0ahUKEwjFldSok-rPAhUkQZoKHTetAhAQ_AUIBygA&dpr=2.2"
        
        do {
            let request = try Request(method: .get, uri: uri)
            XCTAssertEqual(request.baseURL, "https://www.google.co.il:\(request.uri.port!)")
        } catch let e {
            XCTFail("\(e.localizedDescription)")
        }
    }
    
    static var allTests: [(String, (RequestAuthTests) -> () throws -> Void)] {
        return [
            ("testExample", testBaseURL),
        ]
    }
}
