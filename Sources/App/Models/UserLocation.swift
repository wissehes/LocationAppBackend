//
//  UserLocation.swift
//
//
//  Created by Wisse Hes on 18/07/2023.
//

import Foundation
import Vapor
import Fluent

final class UserLocation: Model, Content {
    static let schema = "user_location"

    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Timestamp(key: "timestamp", on: .create)
    var timestamp: Date?
    
    @Field(key: "latitude")
    var latitude: Double
    @Field(key: "longitude")
    var longitude: Double
    
    init() { }
    
    init(id: UUID? = nil, timestamp: Date? = nil, latitude: Double, longitude: Double, userID: User.IDValue) {
        self.id = id
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.$user.id = userID
    }
}

extension UserLocation {
    struct Create: Content {
        var latitude: Double
        var longitude: Double
    }
}
