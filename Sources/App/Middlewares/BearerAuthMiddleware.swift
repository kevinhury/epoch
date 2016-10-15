//
//  BearerAuthMiddleware.swift
//  Epoch
//
//  Created by Kevin Hury on 15/10/2016.
//
//

import Turnstile
import HTTP

class BearerAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let accessToken = request.auth.header?.bearer {
            try? request.auth.login(accessToken, persist: false)
        }
        
        return try next.respond(to: request)
    }
}
