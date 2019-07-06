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
    var midnight:Date{
        let cal = Calendar(identifier: .gregorian)
        return cal.startOfDay(for: self)
    }
}
