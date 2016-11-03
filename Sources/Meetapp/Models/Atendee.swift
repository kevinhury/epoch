//
//  Atendee.swift
//  Epoch
//
//  Created by Kevin Hury on 02/11/2016.
//
//

import Vapor
import Fluent

public final class Atendee: Model {
    public var exists: Bool = false
    
    // Database fields
    public var id: Node?
    var authId: Node?
    var eventId: Node?
    
    public init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.eventId = node["event_id"]
        self.authId = node["auth_id"]
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "auth_id": authId,
            "event_id": eventId
        ])
    }
}

extension Atendee: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create("atendees") { creator in
            creator.id()
            creator.int("auth_id")
            creator.int("event_id")
        }
    }
    
    public static func revert(_ database: Database) throws {}
}

extension Atendee {
    func events() throws -> Siblings<Event> {
        return try siblings()
    }
}
