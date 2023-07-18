//
//  CreateUserLocation.swift
//
//
//  Created by Wisse Hes on 18/07/2023.
//

import Foundation
import Fluent

extension UserLocation {
    struct Migration: AsyncMigration {
        var name: String { "CreateUserLocation" }
        
        func prepare(on database: Database) async throws {
            try await database.schema("user_location")
                .id()
                .field("timestamp", .datetime)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .field("latitude", .double, .required)
                .field("longitude", .double, .required)
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("user_tokens").delete()
        }
    }
    
}
