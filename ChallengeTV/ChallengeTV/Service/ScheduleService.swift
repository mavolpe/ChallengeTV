//
//  ScheduleService.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

typealias ScheduleCache = [Int:(date:Date,schedule:Schedule)]

class ScheduleService {
    private let cacheSizeDays = 7 // TODO - configurable??
    private let countryCode = "US" // TODO - configurable??
    private let scheduleQueue = DispatchQueue(label: "scheduleSyncQueu")
    private let scheduleFetchGroup = DispatchGroup()
    private let scheduleAPI = ScheduleAPI()
    
    private init(){
        
    }
    static let sharedInstance = ScheduleService()
    
    private var scheduleCache:ScheduleCache = [:]
    
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

}
