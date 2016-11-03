//
//  DatePollTests.swift
//  Epoch
//
//  Created by Kevin Hury on 24/10/2016.
//
//

import XCTest
import Vapor
import Fluent
@testable import Meetapp

class DatePollTests: XCTestCase {
    static var allTests: [(String, (DatePollTests) -> () throws -> Void)] {
        return [
            ("testDatePollCreation", testDatePollCreation),
            ("testSelection", testSelection),
            ("testInvalidDateObjectInPoll", testInvalidDateObjectInPoll),
        ]
    }
    
    var database: Database!
    var droplet: Droplet!
    
    override func setUp() {
        database = Database(MemoryDriver())
        
        Event.database = database
        DatePoll.database = database
        DatePollSelection.database = database
        Atendee.database = database
    }
    
    func testDatePollCreation() throws {
        let atendee = try TestsUtils.generateAtendee(eventId: nil)
        guard let atendeeId = atendee.id else { return XCTFail("Saving user model failed.") }
        
        var event = try TestsUtils.generateEvent(ownerId: atendeeId)
        try event.save()
        
        let date = "04 Nov 2014 11:45:34"
        let node = try Node(node: [
            "date": date,
            "event_id": event.id
        ])
        var poll = try DatePoll(node: node)
        try poll.save()
        
        XCTAssertEqual(poll.date, date)
        XCTAssertEqual(poll.eventId, event.id)
        
        let fetchedEvent = try poll.event()
            .makeQuery()
            .first()
        
        XCTAssertEqual(fetchedEvent?.id, event.id)
    }
    
    func testInvalidDateObjectInPoll() {
        do {
            let date = "stam taarih"
            let node = try Node(node: [
                "date": date,
                "event_id": Node(1)
            ])
            var poll = try DatePoll(node: node)
            try poll.save()
            XCTFail("Should throw error on invalid date object.")
        } catch {}
    }
    
    func testSelection() throws {
        let atendee = try TestsUtils.generateAtendee(eventId: nil)
        guard let userId = atendee.id else { return XCTFail("Saving user model failed.") }
        
        var event = try TestsUtils.generateEvent(ownerId: userId)
        try event.save()
        
        guard let eventId = event.id else { return XCTFail("Saving event model failed.") }
        
        var poll = try DatePoll(node: try Node(node: [
            "date": "04 Nov 2014 11:45:34",
            "event_id": eventId
        ]))
        try poll.save()
        
        var selection = try DatePollSelection(node: try Node(node: [
            "atendee_id": userId,
            "datepoll_id": poll.id!
        ]))
        try selection.save()
        
        let selectionUser = try selection
            .atendee()
            .makeQuery()
            .first()
        
        let selectionPoll = try selection
            .datepoll()
            .makeQuery()
            .first()
        
        XCTAssertEqual(selectionUser?.id, userId)
        XCTAssertEqual(selectionPoll?.id, poll.id)
    }
}
