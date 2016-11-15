//
//  Event.swift
//  Epoch
//
//  Created by Kevin Hury on 20/10/2016.
//
//

import Vapor
import Fluent

private let ENTITY_NAME = "events"

final class Event: Model {
    var exists: Bool = false
    
    // Database fields
    var id: Node?
    var name: String
    var description: String
    var location: String
    var photoURL: String = ""
    var rsvpDeadline: Int
    
    var ownerId: Node
    
    init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.ownerId = try node.extract("owner_id")
        self.name = try node.extract("name")
        self.description = try node.extract("description")
        self.location = try node.extract("location")
        self.photoURL = try node.extract("photo_url")
        self.rsvpDeadline = try node.extract("rsvp_deadline")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "owner_id": ownerId,
            "name": name,
            "description": description,
            "location": location,
            "photo_url": photoURL,
            "rsvp_deadline": rsvpDeadline
        ])
    }
    
}

extension Event: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(ENTITY_NAME) { (creator) in
            creator.id()
            creator.int("owner_id")
            creator.string("name")
            creator.string("description")
            creator.string("location")
            creator.string("photo_url")
            creator.int("rsvp_deadline")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(ENTITY_NAME)
    }
}

extension Event {
    func atendees() throws -> Siblings<Atendee> {
        return try siblings()
    }
    
    func owner() throws -> Parent<Atendee> {
        return try parent(ownerId)
    }
}
