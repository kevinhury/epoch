//
//  main.swift
//  Epoch
//
//  Created by Kevin Hury on 15/10/2016.
//
//

import Vapor
import VaporMySQL
import Auth
import EpochAuth
import Meetapp

let drop = Droplet()

try drop.addProvider(VaporMySQL.Provider.self)
drop.addConfigurable(middleware: AuthMiddleware(user: User.self), name: "auth")
drop.preparations.append(User.self)
drop.preparations.append(Post.self)
drop.preparations.append(Event.self)


drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

// Authentication handlers
drop.group("auth") { (group) in
    let usersController: AuthenticationController = UsersController()
    group.post("registration", handler: usersController.register)
    group.post("login", handler: usersController.login)
}

private let baseAuth = BasicAuthMiddleware()
private let protect = ProtectMiddleware(
    error: Abort.custom(status: .unauthorized, message: "Invalid credentials.")
)
drop.grouped(baseAuth, protect).resource("posts", PostController())
drop.grouped(baseAuth, protect).resource("events", EventsController())

drop.run()
