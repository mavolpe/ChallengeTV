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

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testNetworkCommunication(){
        MockServer.sharedInstance.setupMockServer()
        let url = "http://api.mocktvserver.com/schedule?country=US&date=2019-07-11"
        
        let expectation = XCTestExpectation(description: "test network communication")
        NetworkCommunication.sharedInstance.getRequest(urlString: url, customHeaders: [:], options: NetworkCommunication.NetworkRequestOptions.defaultSetting) { (data, netError) in
            if let jsonData = data{
                do{
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    NSLog("#### JSON == \(json)")
                    expectation.fulfill()
                }
                catch {
                    NSLog("#### json error: \(error.localizedDescription)")
                }
                
            }
        }

        wait(for: [expectation], timeout: 10)
    }
    
    func testScheduleApi(){
        let expectation = XCTestExpectation(description: "schedule API tests")
        let tvAPI = TVAPI()
        tvAPI.useMockData = true
        var passed = false
        let startDate = Date.init().midnight
        tvAPI.getSchedule(date: startDate, countryCode: "US") { (schedule, error) in
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
                        }
                    }
                    if passed{
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 10)
        
    }
    
    func testServiceCastFetch(){
        TVService.sharedInstance.useMockData = true
        let showId = 36568
        
        let expectation = XCTestExpectation(description: "Get cast fetch")
        let tvService = TVService.sharedInstance
        tvService.fetchCast(showId: showId) { (cast, error) in
            if let cast = cast{
                if let castMembers = cast.castMembers{
                    
                    XCTAssert(castMembers.count > 0)
                    XCTAssert(castMembers.filter({ (castMember) -> Bool in
                        return castMember.personName == "Will Patton"
                    }).count > 0)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    static var serviceResponded = false

    func testTVServiceObservableAndFiltering() {
        let expectation = XCTestExpectation(description: "Receive update that a schedule is available")
        class MyTVServiceObserver : TVServiceObserver{
            var expectation:XCTestExpectation? = nil
            static let sharedInstance = MyTVServiceObserver()
            func errorEncountered(error: ChallengeTVErrorProtocol?) {
                
            }
            
            func scheduleUpdated() {
                ChallengeTVTests.serviceResponded = true
                TVService.sharedInstance.getScheduleList { [weak self] (schedule) in
                    XCTAssert(schedule.count>0)
                    let result = schedule.filter(filter: "swamp")
                    var testResult = false
                    if result.count > 0{
                        for day in result{
                            if let events = day.schedule.events{
                                for event in events{
                                    NSLog("#### showTitle \(event.showTitle)")
                                    testResult = event.showTitle.contains("Swamp")
                                }
                            }
                        }
                    }
                    // only accept a pass if all the tests contain the show swamp... otherwise let the test timeout and fail...
                    if testResult{
                        self?.expectation?.fulfill()
                    }
                }
                
            }
        }
        ChallengeTVTests.serviceResponded = false
        MyTVServiceObserver.sharedInstance.expectation = expectation
        TVService.sharedInstance.useMockData = true
        TVService.sharedInstance.attachObserver(observer: MyTVServiceObserver.sharedInstance)
        
        TVService.sharedInstance.fetchSchedule()
        
        wait(for: [expectation], timeout: 10.0)
    }
}


