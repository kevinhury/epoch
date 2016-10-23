//
//  DatePoll.swift
//  Epoch
//
//  Created by Kevin Hury on 23/10/2016.
//
//

import Vapor
import Fluent

public final class DatePoll: Model {
    public var exists: Bool = false
    
    // Database fields
    public var id: Node?
    var date: String
    var eventId: Node
    
    public init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.date = try node.extract("date")
        self.eventId = try node.extract("event_id")
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "date": date,
            "event_id": eventId
        ])
    }
}

extension DatePoll: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create("datepolls") { creator in
            creator.id()
            creator.string("date")
            creator.int("event_id")
        }
    }
    
    public static func revert(_ database: Database) throws {}
}
