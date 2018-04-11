//
//  NetworkRequestTests.swift
//  Empyr_Tests
//
//  Created by Jarrod Cuzens on 3/19/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

import Quick
import Nimble
@testable import Empyr

class NetworkRequestsSpec: QuickSpec {
	override func spec() {
		describe("a basic request") {
			it( "has no params and is a GET" ) {
				let url = "https://localhost/get"
				let r = NetworkRequest.get(url: url)
				
				expect( r.params.count ) == 0
				expect( r.methodType ) == NetworkRequest.MethodType.GET
				expect( r.buildUrl().absoluteString ) == url
			}
		}
		
		describe("a request with params") {
			it( "will allow multiple params that are on the query string." ) {
				let url = "https://localhost/get"
				let r = NetworkRequest.get(url: url)
					.addParams(["blah": 1, "test": 2])
				
				expect( r.params.count ) == 2
				expect( r.params["blah"] as? Int ) == 1
				expect( r.buildUrl().absoluteString ) == url + "?blah=1&test=2"
			}
			
			it( "will append params when the url already has some." ) {
				let url = "https://localhost/get?onUrl=true"
				let r = NetworkRequest.get(url: url)
					.addParams( ["blah": 1] )
				
				expect( r.params.count ) == 1
				expect( r.buildUrl().absoluteString ) == url + "&blah=1"
			}
			
			it( "will allow an array of param values and will repeat the param multiple times." ) {
				let url = "https://localhost/get"
				let r = NetworkRequest.get(url: url)
					.addParams( ["blah": [2, 3]] )
				
				expect( r.params.count ) == 1
				expect( r.buildUrl().absoluteString ) == url + "?blah=2&blah=3"
			}
			
		}
		
	}
}
