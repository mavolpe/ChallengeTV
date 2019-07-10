//
//  ChallengeTVError.swift
//  ChallengeTV
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//
// inspiration - https://stackoverflow.com/questions/40671991/generate-your-own-error-code-in-swift-3

import UIKit

enum ChallengeErrorType : Int{
    case CET_UNKNOWN = 10000
    case CET_NO_NETWORK_SESSION = 10001
    case CET_FAILED_TO_PARSE_URL = 10002
    case CET_FAILED_TO_FETCH_SCHEDULE = 10003
    case CET_FAILED_TO_FETCH_CAST = 10004
}

protocol ChallengeTVErrorProtocol: LocalizedError {
    var title: String? { get }
    var code: Int { get }
}

struct ChallengeTVError: ChallengeTVErrorProtocol {
    
    var title: String?
    var code: Int
    var innerError:Error?
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }
    
    private var _description: String
    
    init(title: String?, description: String, code: Int, innerError:Error? = nil) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
        self.innerError = innerError
    }
}

extension ChallengeTVError{
    
    // a convenience function for creating errors
    public static func createError(type:ChallengeErrorType, innerError:Error? = nil)->ChallengeTVError{
        var message = "Unknown"
        switch type {
        case .CET_NO_NETWORK_SESSION:
            message = NSLocalizedString("No network session available", comment:"No network session available")
        case .CET_FAILED_TO_PARSE_URL:
            message = NSLocalizedString("Failed to parse url", comment:"Failed to parse url")
        case .CET_UNKNOWN:
            message = NSLocalizedString("An unknown error occurred", comment:"An unknown error occured")
        case .CET_FAILED_TO_FETCH_SCHEDULE:
            message = NSLocalizedString("Failed to retrieve TV Schedule", comment:"failed to fetch tv schedule")
        case .CET_FAILED_TO_FETCH_CAST:
            message = NSLocalizedString("Failed to fetch cast", comment:"failed to fetch cast")
        }
        return ChallengeTVError.init(title: message, description: message, code: type.rawValue, innerError:innerError)
    }
}
