//
//  EventTests.swift
//  Epoch
//
//  Created by Kevin Hury on 24/10/2016.
//
//

import XCTest
import Fluent
import Turnstile
@testable import Meetapp

class EventTests: XCTestCase {
    static var allTests: [(String, (EventTests) -> () throws -> Void)] {
        return [
            ("testEventCreation", testEventCreation),
            ("testEventOwner", testEventOwner),
            ("testOwnerChildren", testOwnerChildren),
            ("testEventLocationFormat", testEventLocationFormat),
        ]
    }
    
    var owner: Atendee!
    var database: Database!
    
    override func setUp() {
        database = Database(MemoryDriver())
        
        Meetapp.Atendee.database = database
        Meetapp.Event.database = database
        Pivot<Meetapp.Atendee, Meetapp.Event>.database = database
        
        owner = try? TestsUtils.generateAtendee(eventId: nil)
    }
    
    func testEventCreation() throws {
        var event = try TestsUtils.generateEvent(ownerId: owner.id!)
        try event.save()
        
        XCTAssertNotNil(event)
        XCTAssertTrue(event.exists)
        XCTAssertNotNil(event.id)
    }
    
    func testEventOwner() throws {
        var event = try TestsUtils.generateEvent(ownerId: owner.id!)
        try event.save()
        let eventOwner = try event.owner().get()
        
        XCTAssertEqual(eventOwner?.id, owner.id)
    }
    
    func testOwnerChildren() throws {
        var event = try TestsUtils.generateEvent(ownerId: owner.id!)
        try event.save()
        
        let ownersEvent = try owner.events()
            .makeQuery()
            .first()
        
        XCTAssertEqual(ownersEvent?.id, event.id)
    }
    
    func testEventLocationFormat() {
        var node = try! TestsUtils.generateEventNode(ownerId: Node(1))
        
        do {
            node["location"] = "stam location"
            var event = try Event(node: node)
            try event.save()
            XCTFail("Should throw error on invalid location object.")
        } catch {}
    }
}
