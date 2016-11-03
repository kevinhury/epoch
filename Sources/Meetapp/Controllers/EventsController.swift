//
//  EventsController.swift
//  Epoch
//
//  Created by Kevin Hury on 20/10/2016.
//
//

import Vapor
import HTTP

public final class EventsController {
    public init() {}
    
    // Get all events
    //TODO: Remove before production
    func index(request: Request) throws -> ResponseRepresentable {
        return try Event.all().makeNode().converted(to: JSON.self)
    }
    
    
    /**
     * @api {get} /events/userEvents
     *
     * @apiParam {Int} id atendee id.
     *
     * @apiSuccess {[Event]} events array of all user events.
     */
    func eventsById(request: Request) throws -> ResponseRepresentable {
        guard
            let atendeeId = request.json?["ownerId"]?.int
        else {
            throw Abort.badRequest
        }
        
        let events = try Event
            .query()
            .filter("owner_id", atendeeId)
            .all()
            .makeNode()
        
        return try Response(status: .ok, json: try JSON(node: events))
    }
    
    /**
     * @api {get} /events/:id
     *
     * @apiParam {Int} id atendee id.
     *
     * @apiSuccess {Event} event the corresponding event.
     */
    func eventVerboseData(request: Request) throws -> ResponseRepresentable {
        guard
            let eventId = request.parameters["id"]?.int
        else {
            throw Abort.badRequest
        }
        
        guard let event = try Event.find(Node(eventId)) else {
            throw Abort.custom(status: .badRequest, message: "Couldn't find event.")
        }
        
        return event
    }
    
    // Create a new event
    func create(request: Request) throws -> ResponseRepresentable {
        //TODO: validate fields
        var event = try request.event()
        try event.save()
        
        let invitees = try request.invitees(eventId: event.id)
        for var invite in invitees {
            try invite.save()
        }
        
        let polls = try request.polls(eventId: event.id)
        for var poll in polls {
            try poll.save()
        }
        
        return event
    }
    
    // Modify an event
    // Authenticate event owner
    func modify(request: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    
}

extension Request {
    func event() throws -> Event {
        guard let json = json else { throw Abort.badRequest }
        return try Event(node: json)
    }
    
    func invitees(eventId: Node?) throws -> [EventInvite] {
        guard
            let json = json,
            let eventId = eventId
        else {
            throw Abort.badRequest
        }
        let invitees: [String] = try json.extract("invitees")
        return try invitees.map { antendeeId in
            let node = try JSON(node: [
                "state_id": 0,
                "atendee_id": antendeeId,
                "event_id": eventId
            ])
            return try EventInvite(node: node)
        }
    }
    
    func polls(eventId: Node?) throws -> [DatePoll] {
        guard
            let json = json,
            let eventId = eventId
        else {
            throw Abort.badRequest
        }
        
        let dates: [String] = try json.extract("dates")
        return try dates.map { date in
            return try DatePoll(node: try JSON(node: [
                "date": date,
                "event_id": eventId
            ]))
        }
    }
}
