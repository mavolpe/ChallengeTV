//
//  ScheduleService.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//
// inspiration for observer/observable - https://medium.com/@samstone/design-patterns-in-swift-observer-pattern-51274d34f9e3

import UIKit

typealias ScheduleDay = (date:Date,schedule:Schedule)
typealias ScheduleCache = [Int:ScheduleDay]
typealias CastMemberCache = [Int:Cast]

class TVService : TVServiceObservable{
    internal var useMockData = false{
        didSet{
            scheduleAPI.useMockData = useMockData
        }
    }
    private let cacheSizeDays = 7 // For the scope of this project we will limit the schdule to one week
    private let countryCode = "US" // for the scope of this project we will hard code for US
    private let scheduleQueue = DispatchQueue(label: "scheduleSyncQueu")
    private let scheduleProcessingQueue = DispatchQueue(label: "scheduleProcessingQueue")
    private let castProcessingQueue = DispatchQueue(label: "castProcessingQueue")
    private let scheduleFetchGroup = DispatchGroup()
    private let scheduleErrorQueue = DispatchQueue(label: "errorQueue")
    private var scheduleErrorOccurred:Bool = false
    private let scheduleAPI = TVAPI()
    private var refetchScheduled:Bool = false
    
    private override init(){
        super.init()
    }
    static let sharedInstance = TVService()
    
    private var scheduleCache:ScheduleCache = [:]
    private var castCache:CastMemberCache = [:]
    
    public func getScheduleList(completion:@escaping (ScheduleList)->Void){
        var schedule:ScheduleList = []
        scheduleQueue.async { [weak self] in
            guard let this = self else{
                return
            }
            schedule = this.scheduleCache.compactMap({$1}).sorted(by: { $0.date < $1.date})
            DispatchQueue.main.async {
                completion(schedule)
            }
        }
    }
    
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
    
    private func hasError()->Bool{
        var error = false
        self.scheduleErrorQueue.sync { [weak self] in
            guard let this = self else{return}
            error = this.scheduleErrorOccurred
        }
        return error
    }
    
    private func setError(error:Bool){
        self.scheduleErrorQueue.sync { [weak self] in
            guard let this = self else{return}
            this.scheduleErrorOccurred = error
        }
    }
    
    public func fetchSchedule(){
        scheduleProcessingQueue.async { [weak self] in
            guard let this = self else{
                return
            }
            // clear previous errors
            this.setError(error: false)
            let cacheDays = this.getCurrentCacheDays()
            
            for (index,day) in cacheDays.enumerated(){
                guard this.hasError() == false else {
                    break // stop processing jobs
                }
                this.scheduleFetchGroup.enter()
                this.scheduleAPI.getSchedule(date: day, countryCode: this.countryCode) { (schedule, error) in
                    
                    if let schedule = schedule{
                        this.scheduleQueue.sync {
                            this.scheduleCache[index] = (day, schedule)
                        }
                        this.scheduleUpdated()
                    }else if let error = error{
                        this.setError(error: true)
                        this.notifyError(error: error)
                    }
                    this.scheduleFetchGroup.leave()
                }
                
            }
            this.scheduleFetchGroup.notify(queue: DispatchQueue.main) { [weak self] in
                guard let this = self else {return}
                if this.hasError() == false{
                    this.scheduleUpdated()
                    let secondsUntilMidnightTomorrow = Date.init().secondsUntilMidnightTomorrow
                    this.scheduleReFetch(seconds: secondsUntilMidnightTomorrow)
                    NSLog("#### schedule will refresh in \(secondsUntilMidnightTomorrow) seconds - which is \(Date.init(timeIntervalSinceNow: secondsUntilMidnightTomorrow))")
                }else{
                    // if we fail to fetch the schedule for some reason, schedule a retry...
                    this.scheduleReFetch(seconds: 30)
                }
            }
        }
    }
    
    private func scheduleReFetch(seconds:Double){
        // allow only one automatic retry at a time...
        guard refetchScheduled == false else{
            return
        }
        refetchScheduled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: { [weak self] in
            guard let this = self else{
                return
            }
            this.fetchSchedule()
            this.refetchScheduled = false
        })
    }
    
    public func getCurrentCacheDays()->[Date]{
        if scheduleAPI.useMockData == false{
            var cacheDays:[Date] = []
            let day = Date.init().currentWeekMonday.midnight
            for i in 0..<cacheSizeDays{
                cacheDays.append(day.addDays(days: i))
            }
            return cacheDays
        }else{
            var cacheDays:[Date] = []
            if let day = DateFormatter.tvMazeDayFormat.date(from: "2019-07-11")?.midnight{
                for i in 0..<cacheSizeDays{
                    cacheDays.append(day.addDays(days: i))
                }
            }
            return cacheDays
        }
    }
    
    public func fetchCast(showId:Int, completion:@escaping (Cast?, Error?)->Void){
        castProcessingQueue.async { [weak self] in
            guard let this = self else{
                completion(nil, ChallengeTVError.createError(type: .CET_UNKNOWN))
                return
            }

            if let cast = this.castCache[showId]{
                completion(cast, nil)
                return
            }
            
            // we didn't have the cast cached yet - let's fetch them from the API
            let syncGroup = DispatchGroup()
            syncGroup.enter()
            this.scheduleAPI.getCast(showId: showId, completion: { (cast, error) in
                completion(cast, error)
                this.castCache[showId] = cast
                syncGroup.leave()
            })
            syncGroup.wait()
        }
    }
    
    override func shouldNotify() -> Bool {
        var hasData = false
        scheduleQueue.sync { [weak self] in
            guard let this = self else {return}
            hasData = this.scheduleCache.count > 0
        }
        return hasData
    }
}

// MARK: Our Observer protocol
protocol TVServiceObserver{
    func errorEncountered(error:ChallengeTVErrorProtocol?)
    func scheduleUpdated()
}

// MARK: Our observable definition
class TVServiceObservable{
    
    private var observerArray = [TVServiceObserver]()
    private var observerableDispatchQueue:DispatchQueue = DispatchQueue(label: "observerableDispatchQueue")
    
    fileprivate func shouldNotify()->Bool{
        return false
    }
    
    public func attachObserver(observer : TVServiceObserver){
        observerableDispatchQueue.async { [weak self] in
            guard let this = self else{
                return
            }
            this.observerArray.append(observer)
            // as soon as we attach - check the schedule...
            DispatchQueue.global().async {
                // do a quick check and notify this observer right away if we already have data...
                if this.shouldNotify(){
                    DispatchQueue.main.async {
                        observer.scheduleUpdated()
                    }
                }
            }
        }
    }
    
    fileprivate func notifyError(error:ChallengeTVErrorProtocol?){
        observerableDispatchQueue.async {[weak self] in
            guard let this = self else{
                return
            }
            for observer in this.observerArray {
                DispatchQueue.main.async {
                    observer.errorEncountered(error:error)
                }
            }
        }
    }
    
    fileprivate func scheduleUpdated(){
        observerableDispatchQueue.async {[weak self] in
            guard let this = self else{
                return
            }
            for observer in this.observerArray {
                DispatchQueue.main.async {
                    observer.scheduleUpdated()
                }
            }
        }
    }
}
