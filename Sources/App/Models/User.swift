//
//  User.swift
//
//
//  Created by Wisse Hes on 18/07/2023.
//

import Foundation
import Vapor
import Fluent

// Actual User class
final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String
    
    @Children(for: \.$user)
    var locations: [UserLocation]
    
    init() { }

    init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}

// Signup content
extension User {
    struct Create: Content {
        var name: String
        var email: String
        var password: String
//        var confirmPassword: String
    }
    
    struct Public: Content {
        var id: String?
        var name: String
        var email: String
    }
}

// Validations
extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

// Authenticatable extension
extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
    
    func publicVersion() -> User.Public {
        return .init(id: self.id?.uuidString, name: self.name, email: self.email)
    }
}
