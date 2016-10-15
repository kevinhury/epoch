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

let drop = Droplet()

try drop.addProvider(VaporMySQL.Provider.self)
drop.addConfigurable(middleware: AuthMiddleware(user: User.self), name: "auth")
drop.preparations.append(User.self)


drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

drop.run()
