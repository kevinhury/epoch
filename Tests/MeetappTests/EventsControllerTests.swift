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
        request.parameters["id"] = ownerId
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
            "location": "-19.2222;32.20222",
            "photo_url": "",
            "rsvp_deadline": 1234567,
            "dates": Node([
                "2022.12.25 7:00",
                "2022.12.26 7:00"
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
    
    func testEmptyDatesInEventCreateRoute() {
        guard
            let eventNode = try? TestsUtils.generateEventNode(ownerId: Node(1))
        else {
            return XCTFail("Failed creating event.")
        }

        let request = try! Request(method: .post, uri: "*")
        request.json = try! JSON(node: eventNode)
        
        do {
            let controller = EventsController()
            let response = try controller.create(request: request).makeResponse()
            XCTAssertNotEqual(response.status, Status.ok)
        } catch {}
    }
    
    func testModifyEventRoute() {
        guard
            let user = try? TestsUtils.generateAtendee(eventId: nil),
            let ownerId = user.id,
            let event = try? TestsUtils.generateEvent(ownerId: ownerId),
            let eventId = event.id
        else {
            return XCTFail("Failed creating event.")
        }
        
        let descriptionToTest = "abcdefg"
        
        let request = try! Request(method: .patch, uri: "*")
        request.json = try! JSON(node: Node([
            "owner_id": ownerId,
            "event_id": eventId,
            "description": Node(descriptionToTest),
        ]))
        
        do {
            let controller = EventsController()
            let response = try controller.modify(request: request).makeResponse()
            let description = try response.json!.extract("description") as String
            XCTAssertEqual(response.status, Status.ok)
            XCTAssertEqual(description, descriptionToTest)
        } catch {
            XCTFail("Unable to create response")
        }
    }
}
