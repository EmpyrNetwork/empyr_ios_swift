//
//  EmpyrAPIClient.swift
//  Pods
//
//  Created by Jarrod Cuzens on 3/15/18.
//

import Foundation

/// The primary class for integrating the Empyr API within your app.
public class EmpyrAPIClient: NSObject {
	static var main : EmpyrAPIClient? = nil
	
	let BASE_URL				= "https://www.mogl.com/api/v2"
	
	/// The application id of the app that this library is being used by.
	var clientId: String
	/// Identifies the user by their userToken or Empyr userId.
	@objc dynamic var userToken: String?
	
	public class func logToConsole( msg: String ) {
		print( msg );
	}
	
	// MARK: - Initializers
	private init( clientId: String ) {
		self.clientId = clientId
	}
	
	/**
	Initializes an instance of the API with the app client id
	
	This should be done on application startup. Preferably, this call
	should be followed by a call to "identify" the user.
	
	- parameter	clientId:	The clientId assigned to your application.
	
	- returns: An EmpyrAPIClient instance configured with the app's client id.
	*/
	@objc open class func initialize( clientId: String ) -> EmpyrAPIClient {
		main = EmpyrAPIClient( clientId: clientId )
		return main!
	}
	
	
	// MARK: - Singleton access
	/**
	Returns the shared singleton EmpyrAPIClient
	
	- precondition: The EmpyrAPIClient should have previously been initialized through EmpyrAPIClient.initialize()
	
	- returns: The previously configured EmpyrAPIClient.
	*/
	@objc open class func mainInstance() -> EmpyrAPIClient {
		guard let m = main else {
			fatalError( "EmpyrAPIClient must be initialized before calling the main instance." )
		}
		
		return m
	}
	
	// MARK: - Identity management
	/**
	Identifies the applications user to the EmpyrAPIClient.
	
	The userToken is used for tracking impressions back to a user
	and other non-authenticating requests. If the request must be
	authenticated then this is done through the use of an access token.
	
	- parameter userToken: The usertoken of the user using the app.
	*/
	@objc open func identify( userToken: String ) {
		self.userToken = userToken;
	}
	
	// MARK: - API Helpers
	
	/**
	Utility method to call the EmpyrAPI with an API request. Makes
	the overall process of calling API methods simpler.
	
	- parameter url: The url endpoint to call. This will be added to the BASE_URL.
	- parameter params: The query params to be added to the request. This will be in addition to the basic params like client_id.
	- parameter expects: Since all API requests are wrapped in a RestResponse<T> where <T> is naturally a dictionary this parameter is ncessary to inform the client what the name of the expected result(s) will be and what types they are.
	- parameter completionHandler: The endpoint to call after the url rquest has been completed.
	*/
	func get<T,Y: Codable>( url: String, params: [String:Any], expects: [String:Y.Type], completionHandler: @escaping( RestResponse<T>?, Error? ) -> Void ) {
		NetworkRequest.get(url: BASE_URL + url)
			.addHeaders(["Accepts": "application/json"])
			.addParams(["client_id": clientId])
			.addParams(params)
			.execute { (data: Data?, urlResponse: URLResponse?, err: Error?) in
				if let d = data {
					do {
						let result = try JSONDecoder(empyrContext: expects).decode(RestResponse<T>.self, from: d)
						completionHandler(result, nil)
					} catch {
						completionHandler( nil, nil )
					}
				}
			}
	}
}
