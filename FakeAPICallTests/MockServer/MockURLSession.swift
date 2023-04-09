//
//  File.swift
//  FakeAPICallTests
//
//  Created by Giwon Seo on 2023/03/19.
//

import Foundation
import Combine

class MockURLSession: URLSession {
    
    enum RequestType: CaseIterable {
        static var allCases: [RequestType] {
            return [.getPerson(""), .getContactsList, .postToggleBeFriend("")]
        }
        
        case getContactsList, getPerson(String), postToggleBeFriend(String)
        
        var urlRequest: URLRequest {
            return URLRequest(url: URL(string: urlAbsoluteString)!)
        }
        
        var urlAbsoluteString: String {
            switch self {
            case .getPerson(let id): return "https://giwon.getPerson?id=" + id
            case .getContactsList: return "https://giwon.getContactsList"
            case .postToggleBeFriend(let id): return "https://giwon.postToggleBeFriend?id=" + id
            }
        }
        
        static func requestType(absoluteString: String) -> RequestType? {
            
            guard let url = URL.init(string: absoluteString) else { return nil }
            
            if let requestType = RequestType.allCases.filter({absoluteString.contains($0.urlAbsoluteString)}).first {
                
                switch requestType {
                case .getPerson(_):
                    if let params = url.queryParameters,
                        let id = params["id"] {
                        return RequestType.getPerson(id)
                    }
                case .getContactsList:
                    return .getContactsList
                case .postToggleBeFriend(_):
                    if let params = url.queryParameters,
                        let id = params["id"] {
                        return RequestType.postToggleBeFriend(id)
                    }
                }
            }
            
            return nil
        }
        
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        let dataTask = MockDataTask()
        dataTask.completion = completionHandler
        
        if let url = request.url {
            let mockRequestType = MockURLSession.RequestType.requestType(absoluteString: url.absoluteString)
            dataTask.requestType = mockRequestType
        }
        
        return dataTask
    }
    
    
}

class MockDataTask: URLSessionDataTask {
    
    var completion: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> (Void))?
    var requestType: MockURLSession.RequestType?
    
    override func resume() {
        let queue = DispatchQueue.init(label: "queue")
        
        // set random delay time
        var delayTime = 0.0
        
        switch ServerSettings.shared.responseTime {
        case .random:
            delayTime = Double((1..<10).randomElement() ?? 1) / 10.0
        case .oneSecond:
            delayTime = 1
        case .oneTwoSecondAlternate:
            delayTime = MockURLSession.responseDelaySeed == 0 ? 1.0 : 2.0
        }
        
        if MockURLSession.responseDelaySeed == 0 {
            MockURLSession.responseDelaySeed = 1
        } else {
            MockURLSession.responseDelaySeed = 0
        }
        
        queue.asyncAfter(deadline: .now() + delayTime, execute: {
            
            guard let requestType = self.requestType else {
                self.completion?(nil, nil, nil)
                return
            }
            
            let mockData = self.data(from: requestType)
            self.completion?(mockData, nil, nil)
        })
        
    }
    
    private func data(from requestType: MockURLSession.RequestType) -> Data? {
        
        switch requestType {
            case .getPerson(let id):
                
                if let person = DataStorage.shared.people.filter({$0.id == id}).first,
                   let encoded = try? JSONEncoder().encode(person) {
                
                    return encoded
                }
            
            case .getContactsList:
                let contactsResponse = DataStorage.shared.contacts
                let encoded = try? JSONEncoder().encode(contactsResponse)
            
                return encoded
            case .postToggleBeFriend(let id):
                
                // 25% toggle fails
            var isSucceeded = true
            
            switch ServerSettings.shared.failureRatio {
                case .random:
                    isSucceeded = [true, true, true, false].randomElement() ?? true
                case .failureSuccessAlternate:
                    isSucceeded = MockURLSession.failureSeed == 0 ? false : true
                
                    if MockURLSession.failureSeed == 0 {
                        MockURLSession.failureSeed = 1
                    } else {
                        MockURLSession.failureSeed = 0
                    }
                default:
                    break
                }
            
                if isSucceeded {
                    DataStorage.shared.updateContacts(toggleId: id)
                }
            
                let isFriendAsResult = DataStorage.shared.isFriend(id: id) ?? false
            
                let response = ToggleBefriendResponse.init(isFinished: isSucceeded, isFriend: isFriendAsResult, id: id)
            
                let encoded = try? JSONEncoder().encode(response)
                return encoded
                
            }
        
        return nil
    }
}


extension URL {
    public var queryParameters: [String: String]? {
        
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
