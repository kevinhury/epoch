//
//  EventInvite.swift
//  Epoch
//
//  Created by Kevin Hury on 23/10/2016.
//
//

import Vapor
import Fluent

private let ENTITY_NAME = "event_invites"

enum InviteState: Int {
    case Pending = 0
    case Going
    case NotGoing
}

final class EventInvite: Model {
    var exists: Bool = false
    
    // Database fields
    var id: Node?
    var stateId: Int
    var eventId: Node
    var atendeeId: Node
    
    var state: InviteState? {
        return InviteState(rawValue: stateId)
    }
    
    init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.stateId = try node.extract("state_id")
        self.eventId = try node.extract("event_id")
        self.atendeeId = try node.extract("atendee_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "state_id": stateId,
            "event_id": eventId,
            "atendee_id": atendeeId
        ])
    }
}

extension EventInvite: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(ENTITY_NAME) { creator in
            creator.id()
            creator.int("state_id")
            creator.int("event_id")
            creator.int("atendee_id")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(ENTITY_NAME)
    }
}

extension EventInvite {
    func event() throws -> Parent<Event> {
        return try parent(eventId)
    }
    
    func user() throws -> Parent<Atendee> {
        return try parent(atendeeId)
    }
}
