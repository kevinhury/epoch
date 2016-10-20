//
//  Request+Auth.swift
//  Epoch
//
//  Created by Kevin Hury on 15/10/2016.
//
//

import Turnstile
import HTTP

public extension Request {
    // Base URL returns the hostname, scheme, and port in a URL string form.
    var baseURL: String {
        return uri.scheme + "://" + uri.host + (uri.port == nil ? "" : ":\(uri.port!)")
    }
    
    // Exposes the Turnstile subject, as Vapor has a facade on it.
    var subject: Subject {
        return storage["subject"] as! Subject
    }
}
