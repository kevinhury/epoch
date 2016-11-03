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
        
        Meetapp.Event.database = database
        Meetapp.Atendee.database = database
        
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
        
        XCTAssertEqual(response.status, Status.ok)
    }
    
    func testGetUserEventsRoute() {
        guard
            var atendee = try? TestsUtils.generateAtendee(eventId: nil),
            let ownerId = atendee.id,
            var event1 = try? TestsUtils.generateEvent(ownerId: ownerId),
            var event2 = try? TestsUtils.generateEvent(ownerId: ownerId)
        else {
            return XCTFail("Failed instantiating owner or events.")
        }
        
        do {
            try atendee.save()
            try event1.save()
            try event2.save()
        } catch {
            XCTFail("Saving mock models failed.")
        }
        
        let request = try! Request(method: .get, uri: "*")
        request.json = try! JSON(node: ["id": ownerId])
        
        do {
            let controller = EventsController()
            let response = try controller.eventsById(request: request).makeResponse()
            XCTAssertEqual(response.status, Status.ok)
            XCTAssertNotNil(response.json)
            
            let events = response.json?.array
            XCTAssertEqual(events?.count, 2)
        } catch {
            XCTFail("Unexpected response.")
        }
    }
    
    func testGetEventByIdRoute() {
        XCTFail()
    }
    
    func testCreateEventRoute() {
        XCTFail()
    }
    
    func testModifyEventRoute() {
        XCTFail()
    }
}
