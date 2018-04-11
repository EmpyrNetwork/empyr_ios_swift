//
//  RestMeta.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 3/26/18.
//

import Foundation

@objc( EMPMeta) class RestMeta: NSObject, Codable {
	@objc public var code: Int = 0
	@objc public var error: String?
	@objc public var errorDetails: [String:String]?
}
