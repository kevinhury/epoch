//
//  DatePollSelection.swift
//  Epoch
//
//  Created by Kevin Hury on 23/10/2016.
//
//

import Vapor
import EpochAuth
import Fluent

public final class DatePollSelection: Model {
    public var exists: Bool = false
    
    // Database fields
    public var id: Node?
    var userId: Node
    var datepollId: Node
    
    public init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.userId = try node.extract("user_id")
        self.datepollId = try node.extract("datepoll_id")
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": userId,
            "datepoll_id": datepollId
        ])
    }
}

extension DatePollSelection: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create("datepolls_selections") { creator in
            creator.id()
            creator.int("user_id")
            creator.int("datepoll_id")
        }
    }
    
    public static func revert(_ database: Database) throws {}
}

extension DatePollSelection {
    func user() throws -> Parent<EpochAuth.User> {
        return try parent(userId)
    }
    
    func datepoll() throws -> Parent<DatePoll> {
        return try parent(datepollId)
    }
}
