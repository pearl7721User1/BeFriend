//
//  File.swift
//  FakeAPICallTests
//
//  Created by Giwon Seo on 2023/03/19.
//

import Foundation

struct User: Hashable {
    
    let id: String
    let name: String
    let imageUrl: String?
    var isFriend: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func stubUsers() -> [User] {
        
        var users = [User]()
        for i in 0..<10 {
            let newUser = User.init(id: "\(i)", name: "\(i)", imageUrl: nil, isFriend: true)
            users.append(newUser)
        }
        
        return users
    }
}
