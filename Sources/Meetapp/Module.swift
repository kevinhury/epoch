//
//  Module.swift
//  Epoch
//
//  Created by Kevin Hury on 15/11/2016.
//
//

import Vapor
import Fluent
import HTTP
import Routing
import TypeSafeRouting

public final class Module {
    private let droplet: Droplet
    private let eventsController = EventsController()
    private let datepollsController = DatePollsController()
    
    public init(droplet: Droplet) {
        self.droplet = droplet
    }
    
    public func addPreparations() {
        let preparations = [
            Atendee.self,
            DatePoll.self,
            DatePollSelection.self,
            Event.self,
            EventInvite.self,
            Pivot<Event, Atendee>.self,
        ] as [Preparation.Type]
        
        droplet.preparations.append(contentsOf: preparations)
    }
    
    public func registerEventRoutes(routeGroup: RouteGroup<Responder, Droplet>) {
        eventsController.registerRoutes(group: routeGroup)
    }
    
    public func registerVoteRoutes(routeGroup: RouteGroup<Responder, Droplet>) {
        datepollsController.registerRoutes(group: routeGroup)
    }
}
