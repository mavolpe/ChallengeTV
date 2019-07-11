//
//  MockServer.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-11.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

import OHHTTPStubs

class MockServer: NSObject {
    
    public static let sharedInstance = MockServer()
    
    func setupMockServer(){
        let cacheDays = TVService.sharedInstance.getCurrentCacheDays()
        for date in cacheDays{
            let dateString = DateFormatter.tvMazeDayFormat.string(from: date)
            let urlString = String("http://api.mocktvserver.com/schedule?country=US&date=\(dateString)")
            stub(condition: isAbsoluteURLString(urlString)) { _ in
                guard let path = OHPathForFile("mock_schedule_\(dateString).json", type(of: self)) else {
                    preconditionFailure("Could not find expected file in test bundle")
                }
                
                return OHHTTPStubsResponse(
                    fileAtPath: path,
                    statusCode: 200,
                    headers: [ "Content-Type": "application/json" ]
                )
            }
        }
        
        let urlString = "http://api.mocktvserver.com/shows/36568/cast"
        stub(condition: isAbsoluteURLString(urlString)) { _ in
            guard let path = OHPathForFile("cast.json", type(of: self)) else {
                preconditionFailure("Could not find expected file in test bundle")
            }
            
            return OHHTTPStubsResponse(
                fileAtPath: path,
                statusCode: 200,
                headers: [ "Content-Type": "application/json" ]
            )
        }
    }
}
