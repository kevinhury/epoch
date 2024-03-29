//
//  DatePollsController.swift
//  Epoch
//
//  Created by Kevin Hury on 24/10/2016.
//
//

import Vapor
import HTTP
import Routing

final class DatePollsController {
    
    public init() {}
    
    func registerRoutes(group: RouteGroup<Responder, Droplet>, path: String = "datepoll") {
        let grouped = group.grouped(path)
        grouped.post("vote", handler: vote)
    }
    
    /**
     * @api {POST} /vote/
     *
     * @apiParam {Int} atendeeId atendee id.
     * @apiParam {Int} eventId event id.
     * @apiParam {Int} pollId poll id.
     *
     * @apiSuccess {Boolean} status boolean indicating wether the vote is on/off.
     */
    public func vote(request: Request) throws -> ResponseRepresentable {
        guard
            let atendeeId = request.json?["atendeeId"]?.int,
            let pollId = request.json?["pollId"]?.int
        else {
            throw Abort.custom(status: .badRequest, message: "Missing parameters.")
        }
        
        var on: Bool = false
        if let selection = try DatePollSelection
            .query()
            .filter("atendee_id", atendeeId)
            .filter("datepoll_id", pollId)
            .first() {
            try selection.delete()
            on = false
        } else {
            var selection = try DatePollSelection(node: [
                "atendee_id": atendeeId,
                "datepoll_id": pollId
            ])
            try selection.save()
            on = true
        }
        
        return try JSON(node: ["status": on])
    }
}
