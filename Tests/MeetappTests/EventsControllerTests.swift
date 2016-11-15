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
            ("testGetUserEventsRoute", testGetUserEventsRoute),
            ("testGetEventByIdRoute", testGetEventByIdRoute),
            ("testCreateEventRoute", testCreateEventRoute),
            ("testModifyEventRoute", testModifyEventRoute),
        ]
    }
    
    var database: Database!
    var droplet: Droplet!
    
    override func setUp() {
        database = Database(MemoryDriver())
        droplet = Droplet()
        
        Meetapp.Event.database = database
        Meetapp.Atendee.database = database
        Meetapp.DatePoll.database = database
        Meetapp.EventInvite.database = database
        
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
        request.json = try! JSON(node: ["ownerId": ownerId])
        
        do {
            let controller = EventsController()
            let response = try controller.eventsByOwnerId(request: request).makeResponse()
            XCTAssertEqual(response.status, Status.ok)
            XCTAssertNotNil(response.json)
            
            let events = response.json?.array
            XCTAssertEqual(events?.count, 2)
        } catch {
            XCTFail("Unexpected response.")
        }
    }
    
    func testGetEventByIdRoute() {
        guard
            var atendee = try? TestsUtils.generateAtendee(eventId: nil),
            let ownerId = atendee.id,
            var event = try? TestsUtils.generateEvent(ownerId: ownerId)
        else {
            return XCTFail("Failed instantiating owner or events.")
        }
        
        do {
            try atendee.save()
            try event.save()
        } catch {
            XCTFail("Saving mock models failed.")
        }
        
        let request = try! Request(method: .get, uri: "*")
        request.parameters["id"] = event.id
        
        do {
            let controller = EventsController()
            let response = try controller.eventVerboseData(request: request).makeResponse()
            XCTAssertEqual(response.status, Status.ok)
            XCTAssertNotNil(response.json)
            
            let name = response.json?["name"]
            XCTAssertEqual(event.name, name?.string)
        } catch {
            XCTFail("Unexpected response.")
        }
    }
    
    func testCreateEventRoute() {
        guard
            let atendee = try? TestsUtils.generateAtendee(eventId: nil),
            let ownerId = atendee.id
        else {
            return XCTFail("Failed instantiating owner.")
        }

        let mockPayload = try! JSON(node: [
            "owner_id": ownerId,
            "name": "EventName",
            "description": "EventDescription",
            "location": "-123;-123",
            "photo_url": "",
            "rsvp_deadline": 1234567,
            "dates": Node([
                "04 Nov 2014 11:45:34",
                "05 Nov 2014 00:00:00"
            ]),
            "invitees": Node([
                2, 3, 4
            ])
        ])
        let request = try! Request(method: .post, uri: "*")
        request.json = mockPayload
        
        do {
            let controller = EventsController()
            let response = try controller.create(request: request).makeResponse()
            
            XCTAssertEqual(response.status, Status.ok)
        } catch {
            XCTFail("Unexpected response.")
        }
        
        do {
            let events = try Event.query().all()
            XCTAssertEqual(events.count, 1)
            
            let dates = try DatePoll.query().all()
            XCTAssertEqual(dates.count, 2)
            
            let invitees = try EventInvite.query().all()
            XCTAssertEqual(invitees.count, 3)
        } catch {
            XCTFail("Querying data models failed.")
        }
    }
    
    func testModifyEventRoute() {
        XCTFail("unimplemented.")
    }
}
