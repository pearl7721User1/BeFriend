//
//  File.swift
//  FakeAPICallTests
//
//  Created by Giwon Seo on 2023/04/07.
//

import Foundation

struct ServerSettings {
    
    enum ResponseTime: Int {
        case random, oneSecond, oneTwoSecondAlternate
    }
    
    enum FailureRatio: Int {
        case random, noFailure, failureSuccessAlternate
    }
    
    private (set) var responseTime = ResponseTime.random
    private (set) var failureRatio = FailureRatio.random
    
    static var shared: ServerSettings = {
        return ServerSettings()
    }()
    
    mutating func updateResponseTime(to newValue:ResponseTime) {
        self.responseTime = newValue
    }
    
    mutating func updateFailureRatio(to newValue:FailureRatio) {
        self.failureRatio = newValue
    }
}
