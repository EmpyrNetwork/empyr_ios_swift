//
//  RestOfferDetails.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 4/10/18.
//

import Foundation

public enum OfferScheduleType : String, Codable {
	case INCLUDE
	case EXCLUDE
	case REWARD
}

@objc( EMPOfferDetails )public class RestOfferDetails: NSObject, Codable {
	@objc public var hasSchedule = false
	var scheduleType: OfferScheduleType = .EXCLUDE
	@objc public var schedule: [String:[RestVariableReward]] = [:]
}
