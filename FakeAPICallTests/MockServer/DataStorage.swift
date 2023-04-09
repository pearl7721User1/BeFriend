//
//  File.swift
//  FakeAPICallTests
//
//  Created by Giwon Seo on 2023/03/18.
//

import UIKit

struct DataStorage {
    
    static var shared: DataStorage = {
        return DataStorage()
    }()
    
    let people: [PersonResponse] = DataStorage.usersStub()
    var contacts: ContactsResponse = DataStorage.contactsStub()
    
    mutating func updateContacts(toggleId: String) {
        contacts.updateRelationship(toggleId: toggleId)
    }
    
    func isFriend(id: String) -> Bool? {
        return contacts.isFriend(toggleId: id)
    }
    
    static private func usersStub() -> [PersonResponse] {
        
        let allImages = ["https://soupenglish.com/wp-content/uploads/2023/04/Asset-3.png",
        "https://soupenglish.com/wp-content/uploads/2023/04/Asset-2-1.png",
        "https://soupenglish.com/wp-content/uploads/2023/04/Asset-2.png",
        "https://soupenglish.com/wp-content/uploads/2023/04/Asset-10.png",
        "https://soupenglish.com/wp-content/uploads/2023/04/Asset-1.png",
        "https://soupenglish.com/wp-content/uploads/2023/04/Asset-1@2x.png",
        "https://soupenglish.com/wp-content/uploads/2023/04/Asset-60.png",
        "https://soupenglish.com/wp-content/uploads/2023/04/Asset-1@3x.png",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-1.01.03-PM.png",
        "https://soupenglish.com/wp-content/uploads/2023/01/IMG_3409.jpg",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-12.58.37-PM-1024x544.png",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-12.59.22-PM-788x1024.png",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-12.59.33-PM-760x1024.png",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-1.00.05-PM-471x1024.png",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-1.00.29-PM-771x1024.png",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-1.00.36-PM-767x1024.png",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-1.00.55-PM.png",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-1.01.03-PM.png",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-1.01.11-PM.png",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-1.01.29-PM-797x1024.png",
        "https://soupenglish.com/wp-content/uploads/2023/03/Screenshot-2023-03-19-at-12.59.55-PM-1024x735.jpg",
        "https://soupenglish.com/wp-content/uploads/2023/02/IMG_997F74AC37FC-1-2.jpeg"]
        
        let names = ["Giwon", "Sammy", "Uno", "Swift", "Pole", "Kancho", "Taylor", "Tigre", "Pooh", "Kindle"]

        var people = [PersonResponse]()
        
        for i in 0..<names.count {
            let person = PersonResponse.init(id: names[i] + "1234", name: names[i], imageUrl: allImages[i])
            people.append(person)
        }
        
        return people
    }
    
    static private func contactsStub() -> ContactsResponse {
        let people = usersStub()
        let relationships = people.map({RelationshipResponse(isFriend: [true,false].randomElement() ?? true, id: $0.id)})
        let contacts = ContactsResponse.init(relationships: relationships)
        return contacts
    }
}

