//
//  RestVariableReward.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 4/10/18.
//

import Foundation

@objc( EMPVariableReward ) public class RestVariableReward : NSObject, Codable {
	@objc public var id: Int = 0
	@objc public var startsAt: Int = 0
	@objc public var endsAt: Int = 0
	var rewardType: OfferRewardType = .FIXED
	@objc public var discount: Double = 0
	@objc public var active: Bool = false
	@objc public var dayOfWeek: String?
}
