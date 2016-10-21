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

fileprivate extension Request {
    func event() throws -> Event {
        guard let json = json else { throw Abort.badRequest }
        return try Event(node: json)
    }
}
