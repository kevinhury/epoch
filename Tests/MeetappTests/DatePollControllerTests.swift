//
//  DatePollControllerTests.swift
//  Epoch
//
//  Created by Kevin Hury on 24/10/2016.
//
//

import XCTest
import Fluent
import HTTP
import JSON
@testable import Meetapp

class DatePollControllerTests: XCTestCase {
    static var allTests: [(String, (DatePollControllerTests) -> () throws -> Void)] {
        return [
            ("testVoteRoute", testVoteRoute),
        ]
    }
    
    var controller: DatePollsController!
    var database: Database!
    var request: Request!
    var atendee: Atendee!
    
    override func setUp() {
        controller = DatePollsController()
        database = Database(MemoryDriver())
        
        Event.database = database
        DatePoll.database = database
        DatePollSelection.database = database
        Atendee.database = database
        
        atendee = try? TestsUtils.generateAtendee(eventId: nil)
        request = try? Request(method: .post, uri: "*")
    }
    
    func testVoteRoute() {
        var event: Meetapp.Event!
        var poll: Meetapp.DatePoll!
        do {

            event = try TestsUtils.generateEvent(ownerId: atendee.id!)
            poll = try TestsUtils.generatePoll(date: "04 Nov 2014 11:45:34", eventId: event.id!)
        } catch {
            XCTFail("Unable to generate test models.")
        }
        
        request.json = try? JSON(node: [
            "eventId": event.id,
            "pollId": poll.id,
            "atendeeId": atendee.id,
        ])
        
        do {
            let response = try controller.vote(request: request!).makeResponse()
            let status = response.json?["status"]?.bool
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(status, true)

            let response2 = try controller.vote(request: request!).makeResponse()
            let status2 = response2.json?["status"]?.bool
            XCTAssertEqual(response2.status, .ok)
            XCTAssertEqual(status2, false)
        } catch {
            XCTFail("no response")
        }
    }
}
