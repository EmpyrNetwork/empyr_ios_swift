//
//  RestOffer.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 4/10/18.
//

import Foundation

enum OfferRewardType : String, Codable {
	case FIXED
	case PERCENT
}

@objc( EMPOffer ) public class RestOffer: NSObject, Codable {
	@objc public var id: Int = 0
	@objc public var rewardValue: Double = 0
	var rewardType: OfferRewardType = .FIXED
	var rewardMax: Double?
	@objc public var requiresActivation = false
	@objc public var basic = false
	
	@objc public var details: RestOfferDetails?
}
