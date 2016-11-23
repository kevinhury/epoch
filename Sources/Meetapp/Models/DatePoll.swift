//
//  DatePoll.swift
//  Epoch
//
//  Created by Kevin Hury on 23/10/2016.
//
//

import Vapor
import Fluent

private let ENTITY_NAME = "datepolls"

final class DatePoll: Model {
    var exists: Bool = false
    
    // Database fields
    var id: Node?
    var date: String
    var eventId: Node
    
    init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.eventId = try node.extract("event_id")
        
        let date: String = try node.extract("date")
        self.date = try date.validated(by: ValidDate.self).value
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "date": date,
            "event_id": eventId
        ])
    }
}

extension DatePoll: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(ENTITY_NAME) { creator in
            creator.id()
            creator.string("date")
            creator.int("event_id")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(ENTITY_NAME)
    }
}

extension DatePoll {
    func event() throws -> Parent<Event> {
        return try parent(eventId)
    }
    
    func selections() -> Children<DatePollSelection> {
        return children()
    }
}
