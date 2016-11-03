//
//  TestsUtils.swift
//  Epoch
//
//  Created by Kevin Hury on 02/11/2016.
//
//

import Foundation
import Turnstile
import Fluent
@testable import EpochAuth
@testable import Meetapp

class TestsUtils {
    class func generateUser() throws -> EpochAuth.User {
        let credentials = UsernamePassword(username: "moshiko", password: "balagan")
        var user = EpochAuth.User(credentials: credentials)
        try user.save()
        
        return user
    }
    
    class func generateAtendee(eventId: Node?) throws -> Atendee {
        var user = try? generateUser()
        try user?.save()
        
        var atendee = try Atendee(node: [
            "event_id": eventId,
            "auth_id": user?.id
        ])
        try atendee.save()
        
        return atendee
    }
    
    class func generateEvent(ownerId: Node) throws -> Meetapp.Event {
        let node = try Node(node: [
            "owner_id": ownerId,
            "name": "EventName",
            "description": "EventDescription",
            "location": "-19.2222;32.20222",
            "photo_url": "",
            "rsvp_deadline": 123123
        ])
        var event = try Event(node: node)
        try event.save()
        
        return event
    }
    
    class func generatePoll(date: String, eventId: Node) throws -> Meetapp.DatePoll {
        var poll = try DatePoll(node: try Node(node: [
            "date": date,
            "event_id": eventId
        ]))
        try poll.save()
        
        return poll
    }
}
