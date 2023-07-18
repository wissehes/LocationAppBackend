//
//  AuthController.swift
//
//
//  Created by Wisse Hes on 18/07/2023.
//

import Foundation
import Vapor


struct AuthController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        
        auth.post("signup", use: self.signUp)
        
        auth.grouped(User.authenticator())
            .post("login", use: self.login)
        
        auth.grouped(UserToken.authenticator())
            .get("test", use: self.testAuth)
    }
    
    func signUp(req: Request) async throws -> UserToken {
        try User.Create.validate(content: req)
        let data = try req.content.decode(User.Create.self)
        
        let user = try User(
            name: data.name,
            email: data.email,
            passwordHash: Bcrypt.hash(data.password)
        )
        try await user.save(on: req.db)
        
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }
    
    func login(req: Request) async throws -> UserToken {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }
    
    func testAuth(req: Request) async throws -> String {
        return try req.auth.require(User.self).name
    }
    
}
