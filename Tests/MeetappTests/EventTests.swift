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
@testable import EpochAuth
@testable import Meetapp

class EventTests: XCTestCase {
    static var allTests: [(String, (EventTests) -> () throws -> Void)] {
        return [
            ("testEventCreation", testEventCreation),
            ("testEventOwner", testEventOwner),
            ("testOwnerChildren", testOwnerChildren),
        ]
    }
    
    var database: Database!
    var owner: EpochAuth.User!
    
    
    override func setUp() {
        database = Database(MemoryDriver())
        
        EpochAuth.User.database = database
        Meetapp.Event.database = database
        
        let credentials = UsernamePassword(username: "moshiko", password: "balagan")
        owner = EpochAuth.User(credentials: credentials)
        try? owner.save()
    }
    
    func eventNode(userId: Node) throws -> Node {
        return try Node(node: [
            "user_id": userId,
            "name": "EventName",
            "description": "EventDescription",
            "location": "-19.2222;32.20222",
            "photo_url": "",
            "rsvp_deadline": 123123
        ])
    }
    
    func testEventCreation() throws {
        let node = try eventNode(userId: owner.id!)
        var event = try Event(node: node)
        try event.save()
        
        XCTAssertEqual(event.name, try node.extract("name"))
        XCTAssertEqual(event.description, try node.extract("description"))
        XCTAssertEqual(event.location, try node.extract("location"))
        XCTAssertEqual(event.photoURL, try node.extract("photo_url"))
        XCTAssertEqual(event.rsvpDeadline, try node.extract("rsvp_deadline"))
    }
    
    func testEventOwner() throws {
        var event = try Event(node: try eventNode(userId: owner.id!))
        try event.save()
        let eventOwner = try event.owner().get()
        
        XCTAssertEqual(eventOwner?.uniqueID, owner.uniqueID)
        XCTAssertEqual(eventOwner?.apiKeyId, owner.apiKeyId)
    }
    
    func testOwnerChildren() throws {
        var event = try Event(node: try eventNode(userId: owner.id!))
        try event.save()
        
        let ownersEvent = try owner.events()
            .makeQuery()
            .first()
        
        XCTAssertEqual(ownersEvent?.id, event.id)
    }
}
