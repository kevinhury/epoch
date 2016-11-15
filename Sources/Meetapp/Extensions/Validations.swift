//
//  Validations.swift
//  Epoch
//
//  Created by Kevin Hury on 06/11/2016.
//
//

import Vapor

final class LatLng: ValidationSuite {
    typealias InputType = String
    
    static func validate(input value: InputType) throws {
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
