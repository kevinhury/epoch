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
    
    class func generateEvent(userId: Node) throws -> Meetapp.Event {
        let node = try Node(node: [
            "user_id": userId,
            "name": "EventName",
            "description": "EventDescription",
            "location": "-19.2222;32.20222",
            "photo_url": "",
            "rsvp_deadline": 123123
        ])
        
        return try Event(node: node)
    }
}
