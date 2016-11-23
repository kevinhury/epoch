//
//  Validations.swift
//  Epoch
//
//  Created by Kevin Hury on 06/11/2016.
//
//

import Vapor
import Foundation

final class LatLng: ValidationSuite {
    typealias InputType = String
    
    static func validate(input value: String) throws {
        let latlng = value.components(separatedBy: ";")
        guard
            latlng.count == 2,
            let lat = Double(latlng[0]),
            let lng = Double(latlng[1])
        else {
            throw error(with: value)
        }
        
        let latEvaluation = Count<Double>.min(-90) && Count<Double>.max(90)
        let lngEvaluation = Count<Double>.min(-180) && Count<Double>.max(180)
        
        try latEvaluation.validate(input: lat)
        try lngEvaluation.validate(input: lng)
    }
}

final class ValidDate: ValidationSuite {
    typealias InputType = String
    
    static func validate(input value: String) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        guard let _ = formatter.date(from: value) else {
            throw error(with: value)
        }
    }
}
