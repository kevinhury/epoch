//
//  EventsController.swift
//  Epoch
//
//  Created by Kevin Hury on 20/10/2016.
//
//

import Vapor
import HTTP

public final class EventsController: ResourceRepresentable {
    public typealias Model = Event
    
    public init() {}
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Event.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var event = try request.event()
        try event.save()
        return event
    }
    
    public func makeResource() -> Resource<Event> {
        return Resource(
            index: index,
            store: create
        )
    }
}

extension Request {
    func event() throws -> Event {
        guard var json = json else { throw Abort.badRequest }
        
        let userId = try auth.user().uniqueID
        json["user_id"] = try JSON(node: Node(userId))
        
        return try Event(node: json)
    }
    
    func invitees(eventId: Int) throws -> [EventInvite] {
        guard let json = json else { throw Abort.badRequest }
        
        let invitees: [String] = try json.extract("invitees")
        return try invitees.map { userId in
            let node = try JSON(node: [
                "state_id": 0,
                "user_id": userId,
                "event_id": eventId
            ])
            return try EventInvite(node: node)
        }
    }
}
