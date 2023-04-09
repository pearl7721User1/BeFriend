//
//  PersonLoader.swift
//  FakeAPICallTests
//
//  Created by Giwon Seo on 2023/03/22.
//

import Foundation
import Combine

class UserController {
    
    private var getAllUsersSubject = PassthroughSubject<Int, Never>()
    private(set) var getAllUsersOutput: AnyPublisher<[User], Never> = Empty(outputType: [User].self, failureType: Never.self).eraseToAnyPublisher()
    
    private var postToggleUserSubject = PassthroughSubject<String, Never>()
    private(set) var postToggleUsersOutput: AnyPublisher<ToggleBefriendResponse, Never> = Empty.init(outputType: ToggleBefriendResponse.self, failureType: Never.self).eraseToAnyPublisher()
    
    
    private var anyCancellable: AnyCancellable?
    
    init() {
        configureChains()
    }
    
    private func configureChains() {
        
        getAllUsersOutput = getAllUsersSubject
            .flatMap({ value in
                self.allRelationships()
            })
            .map() { relationships in
                relationships.publisher
                    .flatMap { response in
                        self.personResponse(from: response.id).zip(Just(response.isFriend).setFailureType(to: Error.self))
                    }
                    .collect()
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .map({ values in
                return values.map({ User(id: $0.0.id, name: $0.0.name, imageUrl: $0.0.imageUrl, isFriend: $0.1)}).sorted(by: {$0.id < $1.id})
            })
            .receive(on: DispatchQueue.main)
            .replaceError(with: [User]())
            .eraseToAnyPublisher()
        
        
        postToggleUsersOutput = postToggleUserSubject
            .debounce(for: 0.01, scheduler: DispatchQueue.main)
            .flatMap(maxPublishers: .unlimited) { value in
                print("flatMapCalled")
                return self.postToggleIsFriend(id: value)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            
    }
    
    private func allRelationships() -> AnyPublisher<[RelationshipResponse], Error> {
        let publisher = MockURLSession.MockRequestPublisher(urlRequest: MockURLSession.RequestType.getContactsList.urlRequest)
            .decode(type: ContactsResponse.self, decoder: JSONDecoder())
            .map(\.relationships)
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    private func personResponse(from id:String) -> AnyPublisher<PersonResponse, Error> {
        let publisher = MockURLSession.MockRequestPublisher(urlRequest: MockURLSession.RequestType.getPerson(id).urlRequest)
            .decode(type: PersonResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    private func postToggleIsFriend(id: String) -> AnyPublisher<ToggleBefriendResponse, Never> {
        let publisher = MockURLSession.MockRequestPublisher(urlRequest: MockURLSession.RequestType.postToggleBeFriend(id).urlRequest)
            .decode(type: ToggleBefriendResponse.self, decoder: JSONDecoder())
            .replaceError(with: ToggleBefriendResponse.init(isFinished: false, isFriend: false, id: ""))
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    // MARK: - public functions
    func getAllUsers() {
        print("getAllUsers called")
        getAllUsersSubject.send(1)
    }
    
    func toggleUserBeingFriend(id: String) {
        print("toggleUserBeingFriend for \(id) is called")
        postToggleUserSubject.send(id)
    }
    
}
