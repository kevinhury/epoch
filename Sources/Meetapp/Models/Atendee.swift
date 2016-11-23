//
//  Atendee.swift
//  Epoch
//
//  Created by Kevin Hury on 02/11/2016.
//
//

import Vapor
import Fluent

private let ENTITY_NAME = "atendees"

final class Atendee: Model {
    var exists: Bool = false
    
    // Database fields
    var id: Node?
    var authId: Node?
    var eventId: Node?
    
    init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.eventId = node["event_id"]
        self.authId = node["auth_id"]
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "auth_id": authId,
            "event_id": eventId
        ])
    }
}

extension Atendee: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(ENTITY_NAME) { creator in
            creator.id()
            creator.int("auth_id")
            creator.int("event_id")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(ENTITY_NAME)
    }
}

extension Atendee {
    func events() throws -> Siblings<Event> {
        return try siblings()
    }
}
