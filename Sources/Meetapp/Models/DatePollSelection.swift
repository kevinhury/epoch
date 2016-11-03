//
//  DatePollSelection.swift
//  Epoch
//
//  Created by Kevin Hury on 23/10/2016.
//
//

import Vapor
import Fluent

public final class DatePollSelection: Model {
    public var exists: Bool = false
    
    // Database fields
    public var id: Node?
    var atendeeId: Node
    var datepollId: Node
    
    public init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.atendeeId = try node.extract("atendee_id")
        self.datepollId = try node.extract("datepoll_id")
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "atendee_id": atendeeId,
            "datepoll_id": datepollId
        ])
    }
}

extension DatePollSelection: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create("datepolls_selections") { creator in
            creator.id()
            creator.int("atendee_id")
            creator.int("datepoll_id")
        }
    }
    
    public static func revert(_ database: Database) throws {}
}

extension DatePollSelection {
    func atendee() throws -> Parent<Atendee> {
        return try parent(atendeeId)
    }
    
    func datepoll() throws -> Parent<DatePoll> {
        return try parent(datepollId)
    }
}
