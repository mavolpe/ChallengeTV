//
//  ScheduleList.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-11.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

typealias ScheduleList = [ScheduleDay]

// a handy helper to assist in filtering
extension ScheduleList{
    func filter(filter:String)->ScheduleList{
        guard filter.isEmpty == false else{
            return self
        }
        return self.compactMap({
            if let events = $0.schedule.events{
                let filteredEvents = events.filter({ (event) -> Bool in
                    let containsShowName = event.showTitle.lowercased().contains(filter)
                    var containsNetwork = false
                    if let network = event.show?.network?.name{
                        containsNetwork = network.lowercased().contains(filter)
                    }
                    
                    return containsNetwork || containsShowName
                })
                
                guard filteredEvents.count > 0 else{
                    return nil
                }
                let newScheduleDay = ScheduleDay($0.date, Schedule(scheduleDate: $0.date, events: filteredEvents))
                
                return newScheduleDay
            }
            return $0
        })
    }
}
