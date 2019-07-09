//
//  ScheduleService.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

typealias ScheduleCache = [Int:(date:Date,schedule:Schedule)]
typealias CastMemberCache = [Int:Cast]

class TVService {
    private let cacheSizeDays = 7 // TODO - configurable??
    private let countryCode = "US" // TODO - configurable??
    private let scheduleQueue = DispatchQueue(label: "scheduleSyncQueu")
    private let castCashQueue = DispatchQueue(label: "castCashQueue")
    private let castProcessingQueue = DispatchQueue(label: "castProcessingQueue")
    private let scheduleFetchGroup = DispatchGroup()
    private let scheduleAPI = TVAPI()
    
    private init(){
        
    }
    static let sharedInstance = TVService()
    
    private var scheduleCache:ScheduleCache = [:]
    private var castCache:CastMemberCache = [:]
    
    public func getScheduleCache(completion:@escaping (ScheduleCache)->Void){
        var schedule:ScheduleCache = [:]
        scheduleQueue.async { [weak self] in
            guard let this = self else{
                return
            }
            schedule = this.scheduleCache
            DispatchQueue.main.async {
                completion(schedule)
            }
        }
    }
    
    public func fetchSchedule(completion:@escaping ()->Void){
        let cacheDays = getCurrentCacheDays()
        
        for (index,day) in cacheDays.enumerated(){
            scheduleFetchGroup.enter()
            
            scheduleAPI.getSchedule(date: day, countryCode: countryCode) { [weak self] (schedule, error) in
                guard let this = self else{
                    return
                }
                if let schedule = schedule{
                    this.scheduleQueue.sync {
                        this.scheduleCache[index] = (day, schedule)
                    }
                }
                this.scheduleFetchGroup.leave()
            }
            
        }
        scheduleFetchGroup.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    public func getCurrentCacheDays()->[Date]{
        var cacheDays:[Date] = []
        let day = Date.init().currentWeekMonday.midnight
        for i in 0..<cacheSizeDays{
            cacheDays.append(day.addDays(days: i))
        }
        return cacheDays
    }
    
    public func fetchCast(showId:Int, completion:@escaping (Cast?, Error?)->Void){
        castProcessingQueue.async { [weak self] in
            guard let this = self else{
                completion(nil, ChallengeTVError.createError(type: .CET_UNKNOWN))
                return
            }
            //this.castCashQueue.sync {
            // IMPORTANT - we only ever access castCache from inside the castProcessingQueue
            // which is a serial queue... so it can only be accessed by one thread
            // at a time...
            if let cast = this.castCache[showId]{
                NSLog("#### cache hit for \(showId)")
                completion(cast, nil)
                return
            }
            //}
            
            // we didn't have the cast cached yet - let's fetch them from the API
            let syncGroup = DispatchGroup()
            syncGroup.enter()
            this.scheduleAPI.getCast(showId: showId, completion: { (cast, error) in
                completion(cast, error)
                this.castCache[showId] = cast
                syncGroup.leave()
            })
            syncGroup.wait()
            NSLog("")
        }
    }

}
