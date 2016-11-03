//
//  DatePollsController.swift
//  Epoch
//
//  Created by Kevin Hury on 24/10/2016.
//
//

import Vapor
import HTTP

public final class DatePollsController {
    
    public init() {}
    
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
            throw Abort.badRequest
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
