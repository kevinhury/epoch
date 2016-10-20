//
//  UserAuthenticationTests.swift
//  Epoch
//
//  Created by Kevin Hury on 20/10/2016.
//
//

import XCTest
import Vapor
import Fluent
import Auth
import HTTP
@testable import EpochAuth

class UserAuthenticationTests: XCTestCase {
    
    var database: Database!
    var droplet: Droplet!
    
    override func setUp() {
        database = Database(MemoryDriver())
        droplet = Droplet()
        
        droplet.database = database
        
        let authMiddleware = AuthMiddleware(user: EpochAuth.User.self)
        droplet.middleware.append(authMiddleware)
    }
    
    func login(credentials: Credentials) throws -> Response {
        User.database = self.database
        
        let login = try Request(method: .get, uri: "login")
        
        return try self.droplet.respond(to: login)
    }
}
