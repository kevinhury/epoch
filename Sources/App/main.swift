//
//  main.swift
//  Epoch
//
//  Created by Kevin Hury on 15/10/2016.
//
//

import Vapor
import VaporMySQL
import Fluent
import Auth
import EpochAuth
import Meetapp

let drop = Droplet()

try drop.addProvider(VaporMySQL.Provider.self)
drop.addConfigurable(middleware: AuthMiddleware(user: User.self), name: "auth")
drop.preparations.append(User.self)


drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

private let baseAuth = BasicAuthMiddleware()
private let protect = ProtectMiddleware(
    error: Abort.custom(status: .unauthorized, message: "Invalid credentials.")
)


// ******* EPOCHAUTH MODULE *******

drop.group("auth") { (group) in
    let usersController: AuthenticationController = UsersController()
    group.post("registration", handler: usersController.register)
    group.post("login", handler: usersController.login)
}

// ******* MEETAPP MODULE *******

let meetapp = Meetapp.Module(droplet: drop)
meetapp.addPreparations()

drop.grouped(baseAuth, protect).group("events") { group in
    meetapp.registerEventRoutes(routeGroup: group)
}

drop.grouped(baseAuth, protect).group("datepoll") { group in
    meetapp.registerVoteRoutes(routeGroup: group)
}

drop.run()
