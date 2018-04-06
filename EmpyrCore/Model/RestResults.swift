//
//  RestResults.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 3/28/18.
//

import Foundation

class RestResults<T: Codable> : Codable {
	var results: [T]!
	var hits: Int!
}
