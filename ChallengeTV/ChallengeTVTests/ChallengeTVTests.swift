//
//  ChallengeTVTests.swift
//  ChallengeTVTests
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import XCTest
@testable import ChallengeTV

class ChallengeTVTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testNetworkCommunication(){
        let url = "http://api.tvmaze.com/schedule?country=US&date=2014-12-01"
        
        let testGroup = DispatchGroup()
        testGroup.enter()
        var passed = false
        NetworkCommunication.sharedInstance.getRequest(urlString: url, customHeaders: [:], options: NetworkCommunication.NetworkRequestOptions.defaultSetting) { (data, netError) in
            if let jsonData = data{
                do{
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    NSLog("#### JSON == \(json)")
                    passed = true
                }
                catch {
                    NSLog("#### json error: \(error.localizedDescription)")
                }
                
            }
            testGroup.leave()
        }
        testGroup.wait()
        XCTAssert(passed)
    }
    
    func testScheduleApi(){
        let scheduleAPI = ScheduleAPI()
        let testGroup = DispatchGroup()
        testGroup.enter()
        var passed = false
        let startDate = Date.init().midnight
        scheduleAPI.getSchedule(date: startDate, countryCode: "US") { (schedule, error) in
            if let schedule = schedule{
                if let events = schedule.events{
                    if events.count > 0{
                        passed = true
                    }
                    // are any of our dates past our start date?
                    // they shouldn't be...
                    for event in events{
                        if event.startDate < startDate{
                            passed = false
                            break
                        }
                    }
                }
            }
            testGroup.leave()
        }
        testGroup.wait()
        XCTAssert(passed)
    }

}
