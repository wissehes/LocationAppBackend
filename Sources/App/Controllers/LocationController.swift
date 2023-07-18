//
//  LocationController.swift
//
//
//  Created by Wisse Hes on 18/07/2023.
//

import Foundation
import Vapor
import Fluent

struct LocationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let location = routes.grouped("location").grouped(UserToken.authenticator())

        location.get("me", use: self.getMyLocation)
        location.get("all", use: self.getAllMyLocations)
        location.post("set", use: self.setMyLocation)
    }
    
    func getMyLocation(req: Request) async throws -> UserLocation {
        let user = try req.auth.require(User.self)
        let location = try await user.$locations.query(on: req.db).sort(\.$timestamp, .descending).first()
        
        guard let location = location else { throw Abort(.notFound, reason: "No location(s) yet.") }
        
        return location
    }
    
    func getAllMyLocations(req: Request) async throws -> [UserLocation] {
        let user = try req.auth.require(User.self)
        let locations = try await user.$locations.query(on: req.db).all()
        return locations
    }
    
    func setMyLocation(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let data = try req.content.decode(UserLocation.Create.self)
        
        let location = UserLocation(
            latitude: data.latitude,
            longitude: data.longitude,
            userID: try user.requireID()
        )
        try await user.$locations.create(location, on: req.db)
        
        return .ok
    }
}
