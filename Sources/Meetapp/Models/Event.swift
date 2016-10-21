//
//  Event.swift
//  Epoch
//
//  Created by Kevin Hury on 20/10/2016.
//
//

import Vapor
import Fluent
import EpochAuth

public final class Event: Model {
    // Database fields
    public var id: Node?
    var name: String
    var description: String
    var location: String
    var photoURL: String = ""
    var rsvpDeadline: Int
    
    var ownerId: Node
    
    public init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.ownerId = try node.extract("owner_id")
        self.name = try node.extract("name")
        self.description = try node.extract("description")
        self.location = try node.extract("location")
        self.photoURL = try node.extract("photoURL")
        self.rsvpDeadline = try node.extract("rsvpDeadline")
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "owner_id": ownerId,
            "name": name,
            "description": description,
            "location": location,
            "photoURL": photoURL,
            "rsvpDeadline": rsvpDeadline
        ])
    }
    
}

extension Event: Preparation {
    
    public static func prepare(_ database: Database) throws {
        try database.create("events") { (creator) in
            creator.id()
            creator.int("owner_id")
            creator.string("name")
            creator.string("description")
            creator.string("location")
            creator.string("photoURL")
            creator.int("rsvpDeadline")
        }
    }
    
    public static func revert(_ database: Database) throws {}
}

extension Event {
    
    func owner() throws -> Parent<User> {
        return try parent(ownerId)
    }
}

extension User {
    
    func events() throws -> Children<Event> {
        return children()
    }
}
