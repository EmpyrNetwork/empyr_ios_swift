//
//  RestResponse.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 3/26/18.
//

import Foundation

/// Extension to the standard JSONDecoder that allows provided the empyrContext that will be used when decoding the RestResponse.response param.
extension JSONDecoder {
	convenience init<T: Codable>(empyrContext: [String:T.Type]) {
		self.init()
		self.userInfo[.empyrResponseContext] = empyrContext
	}
}

/// The custom key that Empyr will store it's context into.
extension CodingUserInfoKey {
	public static let empyrResponseContext: CodingUserInfoKey = CodingUserInfoKey(rawValue: "empyrResponseContext")!
}

/// Convenience extension to grab the empyrResponseContext property while decoding.
extension Decoder {
	public var empyrResponseContext: [String:Codable.Type]? { return userInfo[.empyrResponseContext] as? [String:Codable.Type] }
}

/// Allows opening existentials. This is necessary because the generic type erasure loses the type information necessary to be able to properly decode the responses. A workaround for the type erasure is to allow the Decodable to decode itself and pass "self" which reports the correct Type (not just the protocol type).
extension Decodable {
	static func callDecode<NestedKey>( container: KeyedDecodingContainer<NestedKey>, key: KeyedDecodingContainer<NestedKey>.Key ) throws -> Decodable? {
		let result = try container.decode(self, forKey: key)
		return result
	}
}

/// The basis of every API request from the EmpyrAPI. The two
/// primary properties are the "meta" and "response" properties.
/// Meta is used to determine the status of the API request and if
/// errors were encountered they will be returned here. The "response"
/// field has a data type which is determined by what the API request
/// was which was originally called hence why it is a generic type.
///
/// Note that the generic is not Decodable because the API naturally
/// returns a [String:Any] dictionary. When decoding a special JSONDecoder
/// init extension is used to provide context to the system to properly
/// map the [String:Any] dictionary.
class RestResponse<T> : Decodable {
	var meta: RestMeta!
	var response: T?
	
	enum CodingKeys: String, CodingKey {
		case meta
		case response
	}
	
	/// Ugly but necessary dummy struct that is used so that we can
	/// iterate over the dictionary for the response param.
	private struct ResponseKeys: CodingKey {
		var intValue: Int?
		var stringValue: String
		
		init?(intValue: Int) { self.intValue = intValue; self.stringValue = "" }
		init?(stringValue: String) { self.stringValue = stringValue }
	}
	
	required init( from decoder: Decoder ) throws {
		var responseMap: [String:Any] = [:]
		
		do {
			// Grab the values from the root container.
			let values = try decoder.container(keyedBy: CodingKeys.self)
			
			// First we can easily decode the meta property.
			meta = try values.decode(RestMeta.self, forKey: .meta)
			
			// The response property is more complex and is actually a dictionary
			// which would be [String:Any]. Typically, there is only one item in
			// the dictionary and so it's much easier for the caller if we can
			// strongly type and set the Response to the value we were expecting.
			guard let expects = decoder.empyrResponseContext else {
				return
			}
			
			// Get all the dictionary keys under "response".
			let responseKeys = try values.nestedContainer(keyedBy: ResponseKeys.self, forKey: .response)
			
			// Go through all the keys.
			for k in responseKeys.allKeys {
				// If we were expecting the key then we'll want to decode it.
				if let type = expects[k.stringValue] {
					// Use the extension method on the Decoder to decode the type and assign it
					// to the responseMap with the given key.
					responseMap[k.stringValue] = try type.callDecode(container: responseKeys, key: k)
				}
			}
			
			// If the responseMap had more than one params (e.g. signupWithCard) then
			// [String:Any] should have been the <T> param. Note the underlying typed
			// values will have still been decoded and aren't simply "Any" type.
			if responseMap.count > 1 {
				response = responseMap as! T
			}else if responseMap.count == 1 {
				// The responseMap only had one value so just assign it to the response field directly.
				response = responseMap.first?.value as! T
			}
		}catch {
			print( "Error deserializing response: \(error)" )
			throw error
		}
	}
}
