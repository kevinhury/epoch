//
//  BasicAuthMiddleware.swift
//  Epoch
//
//  Created by Kevin Hury on 15/10/2016.
//
//

import Turnstile
import HTTP

class BasicAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let apiKey = request.auth.header?.basic {
            try? request.auth.login(apiKey, persist: false)
        }
        
        return try next.respond(to: request)
    }
}
