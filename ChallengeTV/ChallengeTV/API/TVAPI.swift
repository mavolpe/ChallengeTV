//
//  ScheduleAPI.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class TVAPI {
    private let baseAPIPath:String = "http://api.tvmaze.com/"
    
    func getSchedule(date:Date, countryCode:String, completion:@escaping ((Schedule?, ChallengeTVErrorProtocol?)->Void)){
        let dateStr = DateFormatter.tvMazeDayFormat.string(from: date)
        
       let endPoint = String("\(baseAPIPath)schedule?country=\(countryCode)&date=\(dateStr)")
        NetworkCommunication.sharedInstance.getRequest(urlString: endPoint) { (data, error) in
            guard error == nil else{
                completion(nil, ChallengeTVError.createError(type: ChallengeErrorType.CET_FAILED_TO_FETCH_SCHEDULE, innerError: error))
                return
            }
            
            if data != nil{
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.tvMazeAirStamp)
                        let events = try decoder.decode([TVEvent].self, from: data!)
                        let schedule = Schedule(scheduleDate: date, events: events)
                        completion(schedule, nil)
                    }
                    catch{
                        NSLog(error.localizedDescription)
                        completion(nil, ChallengeTVError.createError(type: ChallengeErrorType.CET_FAILED_TO_FETCH_SCHEDULE))
                    }
            }else{
                completion(nil, ChallengeTVError.createError(type: ChallengeErrorType.CET_FAILED_TO_FETCH_SCHEDULE))
            }
        }
    }
    
    func getCast(showId:Int, completion:@escaping ((Cast?, ChallengeTVErrorProtocol?)->Void)){
        
        let endPoint = String("\(baseAPIPath)shows/\(showId)/cast")
        NetworkCommunication.sharedInstance.getRequest(urlString: endPoint) { (data, error) in
            guard error == nil else{
                completion(nil, ChallengeTVError.createError(type: ChallengeErrorType.CET_FAILED_TO_FETCH_CAST))
                return
            }
            
            if data != nil{
                do {
                    let decoder = JSONDecoder()
                    let castMembers = try decoder.decode([CastMember].self, from: data!)
                    let cast = Cast(castMembers: castMembers)
                    completion(cast, nil)
                }
                catch{
                    completion(nil, ChallengeTVError.createError(type: ChallengeErrorType.CET_FAILED_TO_FETCH_CAST, innerError: error))
                }
            }else{
                completion(nil, ChallengeTVError.createError(type: ChallengeErrorType.CET_FAILED_TO_FETCH_CAST))
            }
        }
    }
}
