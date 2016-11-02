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
import EpochAuth
@testable import Meetapp

class DatePollTests: XCTestCase {
    static var allTests: [(String, (DatePollTests) -> () throws -> Void)] {
        return [
            ("testDatePollCreation", testDatePollCreation),
            ("testSelection", testSelection),
        ]
    }
    
    var database: Database!
    var droplet: Droplet!
    var user: EpochAuth.User!
    
    override func setUp() {
        database = Database(MemoryDriver())
        
        Event.database = database
        DatePoll.database = database
        DatePollSelection.database = database
        EpochAuth.User.database = database
        
        user = try? TestsUtils.generateUser()
        try? user.save()
    }
    
    func testDatePollCreation() throws {
        guard let userId = user.id else { return XCTFail("Saving user model failed.") }
        
        var event = try TestsUtils.generateEvent(userId: userId)
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
    
    func testSelection() throws {
        var user = try TestsUtils.generateUser()
        try user.save()
        
        guard let userId = user.id else { return XCTFail("Saving user model failed.") }
        
        var event = try TestsUtils.generateEvent(userId: userId)
        try event.save()
        
        guard let eventId = event.id else { return XCTFail("Saving event model failed.") }
        
        var poll = try DatePoll(node: try Node(node: [
            "date": "04 Nov 2014 11:45:34",
            "event_id": eventId
        ]))
        try poll.save()
        
        var selection = try DatePollSelection(node: try Node(node: [
            "user_id": userId,
            "datepoll_id": poll.id!
        ]))
        try selection.save()
        
        let selectionUser = try selection
            .user()
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
