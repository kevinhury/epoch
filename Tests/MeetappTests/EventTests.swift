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
        
        owner = try? TestsUtils.generateUser()
        try? owner.save()
    }
    
    func testEventCreation() throws {
        var event = try TestsUtils.generateEvent(userId: owner.id!)
        try event.save()
        
        XCTAssertNotNil(event)
        XCTAssertTrue(event.exists)
        XCTAssertNotNil(event.id)
    }
    
    func testEventOwner() throws {
        var event = try TestsUtils.generateEvent(userId: owner.id!)
        try event.save()
        let eventOwner = try event.owner().get()
        
        XCTAssertEqual(eventOwner?.uniqueID, owner.uniqueID)
        XCTAssertEqual(eventOwner?.apiKeyId, owner.apiKeyId)
    }
    
    func testOwnerChildren() throws {
        var event = try TestsUtils.generateEvent(userId: owner.id!)
        try event.save()
        
        let ownersEvent = try owner.events()
            .makeQuery()
            .first()
        
        XCTAssertEqual(ownersEvent?.id, event.id)
    }
}
