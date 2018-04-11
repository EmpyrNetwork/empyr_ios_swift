//
//  RestBusiness.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 3/26/18.
//

import Foundation

@objc( EMPBusiness ) public class RestBusiness: NSObject, Codable {
	@objc public var id: Int = 0
	@objc public var name: String = ""
	@objc public var offers: [RestOffer] = []
}
