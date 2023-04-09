//
//  File.swift
//  FakeAPICallTests
//
//  Created by Giwon Seo on 2023/03/19.
//

import UIKit

struct PersonResponse: Codable {
    
    let id: String
    let name: String
    let imageUrl: String?
}

struct ContactsResponse: Codable {
    var relationships: [RelationshipResponse]
    
    func isFriend(toggleId: String) -> Bool? {
        if let index = relationships.firstIndex(where: {$0.id == toggleId}) {
            return relationships[index].isFriend
        }
        
        return nil
    }
    
    mutating func updateRelationship(toggleId: String) {
        if let index = relationships.firstIndex(where: {$0.id == toggleId}) {
            relationships[index].isFriend.toggle()
        }
    }
}

struct RelationshipResponse: Codable {
    var isFriend: Bool
    let id: String
}

struct ToggleBefriendResponse: Codable {
    let isFinished: Bool
    
    let isFriend: Bool
    let id: String
}
