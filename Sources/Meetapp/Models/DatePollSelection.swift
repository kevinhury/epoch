//
//  DatePollSelection.swift
//  Epoch
//
//  Created by Kevin Hury on 23/10/2016.
//
//

import Vapor
import Fluent

private let ENTITY_NAME = "datepolls_selections"

final class DatePollSelection: Model {
    var exists: Bool = false
    
    // Database fields
    var id: Node?
    var atendeeId: Node
    var datepollId: Node
    
    init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.atendeeId = try node.extract("atendee_id")
        self.datepollId = try node.extract("datepoll_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "atendee_id": atendeeId,
            "datepoll_id": datepollId
        ])
    }
}

extension DatePollSelection: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(ENTITY_NAME) { creator in
            creator.id()
            creator.int("atendee_id")
            creator.int("datepoll_id")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(ENTITY_NAME)
    }
}

extension DatePollSelection {
    func atendee() throws -> Parent<Atendee> {
        return try parent(atendeeId)
    }
    
    func datepoll() throws -> Parent<DatePoll> {
        return try parent(datepollId)
    }
}
