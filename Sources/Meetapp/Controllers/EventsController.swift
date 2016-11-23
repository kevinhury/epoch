//
//  EventsController.swift
//  Epoch
//
//  Created by Kevin Hury on 20/10/2016.
//
//

import Vapor
import HTTP
import Routing
import Auth

final class EventsController {
    init() {}
    
    func registerRoutes(group: RouteGroup<Responder, Droplet>, path: String = "events") {
        let grouped = group.grouped(path)
        grouped.get("index", handler: index)
        grouped.get("eventsByOwnerId", ":id", handler: eventsByOwnerId)
        grouped.get("", ":id", handler: eventVerboseData)
        grouped.post("create", handler: create)
        grouped.patch("changeInviteeStatus", handler: changeInviteeStatus)
        grouped.patch("modify", handler: modify)
    }
    
    // Get all events
    //TODO: Remove before production
    func index(request: Request) throws -> ResponseRepresentable {
        return try Event.all().makeNode().converted(to: JSON.self)
    }
    
    
    /**
     * @api {get} /events/userEvents
     *
     * @apiParam {Int} ownerId atendee id.
     *
     * @apiSuccess {[Event]} events array of all user events.
     */
    func eventsByOwnerId(request: Request) throws -> ResponseRepresentable {
        guard
            let atendeeId = request.parameters["id"]?.int
        else {
            throw Abort.custom(status: .badRequest, message: "Missing parameters.")
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
            throw Abort.custom(status: .badRequest, message: "Missing parameters.")
        }
        
        guard let event = try Event.find(Node(eventId)) else {
            throw Abort.custom(status: .badRequest, message: "Couldn't find event.")
        }
        
        return event
    }
    
    /**
     * @api {post} /events/create
     * apiParam {Int} owner_id _
     * apiParam {String} name _
     * apiParam {String} description _
     * apiParam {String} location _
     * apiParam {String} photo_url _
     * apiParam {Int} rsvp_deadline _
     *
     * apiSuccess {Event} event the corresponding event.
     */
    func create(request: Request) throws -> ResponseRepresentable {
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
    
    /**
     * @api {patch}
     *
     * apiParam {Int} atendee_id
     * apiParam {Int} event_id
     * apiParam {Int} state
     *
     * apiSuccess {EventInvite}
     */
    func changeInviteeStatus(request: Request) throws -> ResponseRepresentable {
        guard
            let atendee_id = request.json?["atendee_id"]?.int,
            let event_id = request.json?["event_id"]?.int,
            let state = request.json?["state"]?.int,
            let inviteState = InviteState(rawValue: state)
        else {
            throw Abort.custom(status: .badRequest, message: "Missing parameters.")
        }
        
        guard var invite = try EventInvite
            .query()
            .filter("atendee_id", atendee_id)
            .filter("event_id", event_id)
            .first()
        else {
            throw Abort.custom(status: .badRequest, message: "Invalid invite parameters.")
        }
        
        invite.state = inviteState.rawValue
        try invite.save()
        
        return invite
    }
    
    /**
     * @api {patch} /events/modify
     * apiParam {Int} owner_id
     * apiParam {Int} event_id
     *
     * apiSuccess {Event} event the modified event.
     */
    func modify(request: Request) throws -> ResponseRepresentable {
        guard
            let owner_id = request.json?["owner_id"]?.int,
            let event_id = request.json?["event_id"]?.int
        else {
            throw Abort.badRequest
        }
        
//        guard owner_id == try request.auth.user().id?.int else {
//            
//        }
        
        guard var event = try Event
            .query()
            .filter("id", Node(event_id))
            .filter("owner_id", Node(owner_id))
            .first()
        else {
            throw Abort.badRequest
        }
        
        if let name = request.json?["name"]?.string {
            event.name = name
        }
        
        if let description = request.json?["description"]?.string {
            event.description = description
        }
        
        if let rsvp_deadline = request.json?["location"]?.int {
            event.rsvpDeadline = rsvp_deadline
        }
        
        if let photo_url = request.json?["photo_url"]?.string {
            event.photoURL = photo_url
        }
        
        if let location = request.json?["location"]?.string {
            event.location = location
        }
        
        //TODO: Modify Invitees
        //TODO: Modify dates
        
        try event.save()
        return event
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
