//
//  EventsControllerTests.swift
//  Epoch
//
//  Created by Kevin Hury on 23/10/2016.
//
//

import XCTest
import Vapor
import Fluent
import JSON
import HTTP
@testable import Meetapp

class EventsControllerTests: XCTestCase {
    static var allTests: [(String, (EventsControllerTests) -> () throws -> Void)] {
        return [
            ("testExample", testRequestInviteesParser),
        ]
    }
    
    var database: Database!
    var droplet: Droplet!
    
    override func setUp() {
        database = Database(MemoryDriver())
        droplet = Droplet()
        
        droplet.database = database
    }
    
    func testRequestInviteesParser() {
        let mock = JSON(node: [
            
        ])
        
        let request = Request(method: .get, uri: "create")
        
        droplet.post("create") { request in
            
        }
        
        guard let response = try? droplet.respond(to: request) else { XCTFail() }
    }
}
