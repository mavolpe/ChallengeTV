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
    
    func getSchedule(date:Date, countryCode:String, completion:@escaping ((Schedule?, Error?)->Void)){
        let dateStr = DateFormatter.tvMazeDayFormat.string(from: date)
        
       let endPoint = String("\(baseAPIPath)schedule?country=\(countryCode)&date=\(dateStr)")
        NetworkCommunication.sharedInstance.getRequest(urlString: endPoint) { (data, error) in
            guard error == nil else{
                completion(nil, error)
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
                        // TODO: we need a custom error message here...
                        NSLog(error.localizedDescription)
                        completion(nil, nil)
                    }
            }else{
                // TODO: we need a custom error here - no data received...
                completion(nil, nil)
            }
        }
    }
    
    func getCast(showId:Int, completion:@escaping ((Cast?, Error?)->Void)){
        
        let endPoint = String("\(baseAPIPath)shows/\(showId)/cast")
        NetworkCommunication.sharedInstance.getRequest(urlString: endPoint) { (data, error) in
            guard error == nil else{
                completion(nil, error)
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
                    // TODO: we need a custom error message here...
                    NSLog(error.localizedDescription)
                    completion(nil, nil)
                }
            }else{
                // TODO: we need a custom error here - no data received...
                completion(nil, nil)
            }
        }
    }
}
