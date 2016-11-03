//
//  EventInvite.swift
//  Epoch
//
//  Created by Kevin Hury on 23/10/2016.
//
//

import Vapor
import Fluent

enum InviteState: Int {
    case Pending = 0
    case Going
    case NotGoing
}

public final class EventInvite: Model {
    public var exists: Bool = false
    
    // Database fields
    public var id: Node?
    public var stateId: Int
    public var eventId: Node
    public var atendeeId: Node
    
    var state: InviteState? {
        return InviteState(rawValue: stateId)
    }
    
    public init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.stateId = try node.extract("state_id")
        self.eventId = try node.extract("event_id")
        self.atendeeId = try node.extract("atendee_id")
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "state_id": stateId,
            "event_id": eventId,
            "atendee_id": atendeeId
        ])
    }
}

extension EventInvite: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create("event_invites") { creator in
            creator.id()
            creator.int("state_id")
            creator.int("event_id")
            creator.int("atendee_id")
        }
    }
    
    public static func revert(_ database: Database) throws {}
}

extension EventInvite {
    func event() throws -> Parent<Event> {
        return try parent(eventId)
    }
    
    func user() throws -> Parent<Atendee> {
        return try parent(atendeeId)
    }
}
