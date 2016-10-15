//
//  UsersController.swift
//  Epoch
//
//  Created by Kevin Hury on 15/10/2016.
//
//

import HTTP
import Turnstile
import JSON

/**
 
 */
final class UsersController {
    
    /**
     
     */
    func login(request: Request) throws -> ResponseRepresentable {
        guard
            let username = request.formURLEncoded?["username"]?.string,
            let password = request.formURLEncoded?["password"]?.string
            else {
                throw IncorrectCredentialsError()
        }
        
        let credentials = UsernamePassword(username: username, password: password)
        
        do {
            try request.auth.login(credentials, persist: false)
        } catch _ {
            return try JSON(node: [
                "err": IncorrectCredentialsError().description,
                "success": false
                ])
        }
        
        let user = try request.auth.user() as! User
        
        return try JSON(node: [
            "err": nil,
            "success": true,
            "api_id": user.apiKeyId,
            "api_secret": user.apiKeySecret
            ])
    }
    
    /**
     
     */
    func register(request: Request) throws -> ResponseRepresentable {
        guard
            let username = request.formURLEncoded?["username"]?.string,
            let password = request.formURLEncoded?["password"]?.string
            else {
                throw IncorrectCredentialsError()
        }
        
        let credentials = UsernamePassword(username: username, password: password)
        do {
            try _ = User.register(credentials: credentials)
        } catch _ {
            return try JSON(node: [
                "err": IncorrectCredentialsError().description,
                "success": false
                ])
        }
        do {
            try request.auth.login(credentials, persist: false)
        } catch let e {
            return try JSON(node: [
                "err": e.localizedDescription,
                "success": false
                ])
        }
        
        return try JSON(node: [
            "err": nil,
            "success": true
            ])
    }
}
