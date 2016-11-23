//
//  DatePollControllerTests.swift
//  Epoch
//
//  Created by Kevin Hury on 24/10/2016.
//
//

import XCTest
import Vapor
import Fluent
import HTTP
import JSON
@testable import Meetapp

class DatePollControllerTests: XCTestCase {
    static var allTests: [(String, (DatePollControllerTests) -> () throws -> Void)] {
        return [
            ("testVoteRoute", testVoteRoute),
            ("testMissingParamsInVoteRoute", testMissingParamsInVoteRoute),
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
            poll = try TestsUtils.generatePoll(date: "2016.12.25 7:00", eventId: event.id!)
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
    
    func testMissingParamsInVoteRoute() {
        request.json = try? JSON(node: [
            "eventId": 1,
            "pollId": 2,
            "atendeeId": 3,
        ])
        ["pollId", "atendeeId"].forEach { param in
            request.json?[param] = nil
            do {
                _ = try controller.vote(request: request!)
                XCTFail("No error for missing parameter was thrown.")
            } catch Abort.custom(_, let message) {
                XCTAssertEqual(message, "Missing parameters.")
            } catch {
                XCTFail("Unkown error occured.")
            }
        }
    }
}
