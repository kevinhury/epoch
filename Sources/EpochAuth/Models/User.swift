//
//  User.swift
//  Epoch
//
//  Created by Kevin Hury on 15/10/2016.
//
//

import Fluent
import Auth
import Turnstile
import TurnstileWeb
import TurnstileCrypto


public final class User: Auth.User {
    public var exists: Bool = false
    
    // Database fields
    public var id: Node?
    var username: String
    var password = ""
    var facebookId = ""
    var googleId = ""
    var apiKeyId = URandom().secureToken
    var apiKeySecret = URandom().secureToken
    
    public init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.username = try node.extract("username")
        self.password = try node.extract("password")
        self.facebookId = try node.extract("facebook_id")
        self.googleId = try node.extract("google_id")
        self.apiKeyId = try node.extract("api_key_id")
        self.apiKeySecret = try node.extract("api_key_secret")
    }
    
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "username": username,
            "password": password,
            "facebook_id": facebookId,
            "google_id": googleId,
            "api_key_id": apiKeyId,
            "api_key_secret": apiKeySecret
            ])
    }
    
    public static func authenticate(credentials: Credentials) throws -> Auth.User {
        var user: User?
        
        switch credentials {
            /**
             Fetches a user, and checks that the password is present, and matches.
             */
        case let credentials as UsernamePassword:
            let fetchedUser = try User.query()
                .filter("username", credentials.username)
                .first()
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
            
            /**
             Fetches the user by session ID. Used by the Vapor session manager.
             */
        case let credentials as Identifier:
            user = try User.find(credentials.id)
            
            /**
             Fetches the user by Facebook ID. If the user doesn't exist, autoregisters it.
             */
        case let credentials as FacebookAccount:
            if let existing = try User.query()
                .filter("facebook_id", credentials.uniqueID)
                .first() {
                user = existing
            } else {
                user = try User.register(credentials: credentials) as? User
            }
            
            /**
             Fetches the user by Google ID. If the user doesn't exist, autoregisters it.
             */
        case let credentials as GoogleAccount:
            if let existing = try User.query()
                .filter("google_id", credentials.uniqueID)
                .first() {
                user = existing
            } else {
                user = try User.register(credentials: credentials) as? User
            }
            
            /**
             Authenticates via API Keys.
             */
        case let credentials as APIKey:
            user = try User.query()
                .filter("api_key_id", credentials.id)
                .filter("api_key_secret", credentials.secret)
                .first()
            
            /**
             Authenticates via Access Token.
             */
        case _ as AccessToken:
            throw UnsupportedCredentialsError()
            
        default:
            throw UnsupportedCredentialsError()
        }
        
        if let user = user {
            return user
        } else {
            throw IncorrectCredentialsError()
        }
    }
    
    public static func register(credentials: Credentials) throws -> Auth.User {
        var newUser: User
        
        switch credentials {
        case let credentials as UsernamePassword:
            newUser = User(credentials: credentials)
        case let credentials as FacebookAccount:
            newUser = User(credentials: credentials)
        case let credentials as GoogleAccount:
            newUser = User(credentials: credentials)
        default:
            throw UnsupportedCredentialsError()
        }
        
        if try User.query()
            .filter("username", newUser.username)
            .first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
    }
    
    init(credentials: UsernamePassword) {
        self.username = credentials.username
        self.password = BCrypt.hash(password: credentials.password)
    }
    
    init(credentials: FacebookAccount) {
        self.username = "fb" + credentials.uniqueID
        self.facebookId = credentials.uniqueID
    }
    
    init(credentials: GoogleAccount) {
        self.username = "goog" + credentials.uniqueID
        self.googleId = credentials.uniqueID
    }
}

extension User: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create("users") { (creator: Schema.Creator) in
            creator.id()
            creator.string("username")
            creator.string("password")
            creator.string("facebook_id")
            creator.string("google_id")
            creator.string("api_key_id")
            creator.string("api_key_secret")
        }
    }
    public static func revert(_ database: Database) throws {}
}
