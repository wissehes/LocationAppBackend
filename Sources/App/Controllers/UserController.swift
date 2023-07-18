//
//  UserController.swift
//
//
//  Created by Wisse Hes on 18/07/2023.
//

import Foundation
import Vapor

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("user").grouped(UserToken.authenticator())
        users.get("me", use: self.me)
    }
    
    func me(req: Request) async throws -> User.Public {
        return try req.auth.require(User.self).publicVersion()
    }
    
}
