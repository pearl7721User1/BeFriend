//
//  File.swift
//  FakeAPICallTests
//
//  Created by Giwon Seo on 2023/03/19.
//

import UIKit
import Combine

extension MockURLSession {
    
    static var responseDelaySeed: Int = 0
    static var failureSeed: Int = 0
    
    class MockRequestSubscription<S: Subscriber>: Subscription where S.Input == Data, S.Failure == Error {
        private let urlSession = MockURLSession.init()
        private let urlRequest: URLRequest
        private var subscriber: S?
        
        init(request: URLRequest, subscriber: S) {
            self.urlRequest = request
            self.subscriber = subscriber
            sendRequest()
        }
        
        func request(_ demand: Subscribers.Demand) {
            // Adjust the demand in case you need to
        }
        
        func cancel() {
            subscriber = nil
        }
        
        private func sendRequest() {
            guard let subscriber = subscriber else { return }
            
            
            urlSession.dataTask(with: urlRequest) { (data, _, error) in
                
                if let data = data {
                    subscriber.receive(data)
                }
                
                if let error = error {
                    subscriber.receive(completion: .failure(error))
                } else {
                    subscriber.receive(completion: .finished)
                }
                
            }.resume()
        }
    }
    
    struct MockRequestPublisher: Publisher {
        typealias Output = Data
        typealias Failure = Error
        
        private let urlRequest: URLRequest
        
        init(urlRequest: URLRequest) {
            self.urlRequest = urlRequest
        }
        
        func receive<S: Subscriber>(subscriber: S) where
        MockRequestPublisher.Failure == S.Failure, MockRequestPublisher.Output == S.Input {
                let subscription = MockRequestSubscription(request: urlRequest,
                                                    subscriber: subscriber)
                subscriber.receive(subscription: subscription)
        }
    }
}
