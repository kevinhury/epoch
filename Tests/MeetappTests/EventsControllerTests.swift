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
            ("testRequestInviteesParser", testRequestInviteesParser),
        ]
    }
    
    var database: Database!
    var droplet: Droplet!
    
    override func setUp() {
        database = Database(MemoryDriver())
        droplet = Droplet()
        
        droplet.database = database
    }
    
    func testRequestInviteesParser() throws {
        let mock = try JSON(node: [
            "invitees": Node(node: ["kevin", "gabi"])
        ])
        
        let request = try Request(method: .get, uri: "*")
        request.json = mock
        
        droplet.get("*") { request in
            let invitees = try request.invitees(eventId: 2)
            XCTAssertEqual(invitees.count, 2)
            invitees.forEach { invite in
                XCTAssertEqual(invite.eventId, 2)
                XCTAssertNotNil(invite.state)
                XCTAssertEqual(invite.state, InviteState.Pending)
            }
            return ""
        }
        
        let response = try droplet.respond(to: request)
        
        XCTAssertNotEqual(response.status, Status.notFound)
    }
}
