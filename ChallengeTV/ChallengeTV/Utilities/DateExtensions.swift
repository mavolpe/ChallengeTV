//
//  DateExtensions.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

extension Date {
    // thank you - https://stackoverflow.com/questions/49215366/how-to-find-midnight-for-a-given-date-in-swift?rq=1
    // and... https://stackoverflow.com/questions/33397101/how-to-get-mondays-date-of-the-current-week-in-swift
    
    var midnight:Date{
        let cal = Calendar(identifier: .gregorian)
        return cal.startOfDay(for: self)
    }
    
    var currentWeekMonday: Date {
        return Calendar.iso8601.date(from: Calendar.iso8601.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    func addDays(days:Int)->Date{
        guard days > 0 else{
            return self
        }
        let plusDays = Date(timeInterval: TimeInterval(days*86400), since: self)
        return plusDays
    }
}

extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
}
