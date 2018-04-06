//
//  RestMeta.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 3/26/18.
//

import Foundation

class RestMeta: Codable {
	var code: Int
	var error: String?
	var errorDetails: [String:String]?
}
