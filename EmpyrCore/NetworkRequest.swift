//
//  NetworkRequest.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 3/05/18.
//

import Foundation

extension String: Error {}

/// Simple HTTP utility class to wrap URLSession and make it friendlier without introducing extra dependencies.
public class NetworkRequest {
	public enum MethodType : String {
		case GET
		case POST
	}
	
	var methodType : MethodType
	var url : String
	var params = [String: Any]()
	var datas = [String: Any]()
	var headers = [String: Any]()
	
	/**
	Initializes a new network request with the given url and http method.
	
	- parameter type:	The type of http method
	- parameter url:	The url to perform the request to.
	
	- returns: returns a properly initialized request instance that can be built with the builder pattern.
	*/
	private init(_ type: MethodType, _ url: String ) {
		self.methodType = type;
		self.url = url;
	}
	
	/**
	Create a new "GET" request
	
	- parameter url:	The url to "GET" a resource
	
	- returns: returns a GET NetworkRequest that can be built with the builder pattern.
	*/
	static func get( url: String ) -> NetworkRequest {
		return NetworkRequest( MethodType.GET, url )
	}
	
	/**
	Create a new "POST" request
	
	- parameter url:	The url to "POST" to
	
	- returns: returns a POST NetworkRequest that can be built with the builder pattern.
	*/
	static func post( url: String ) -> NetworkRequest {
		return NetworkRequest( MethodType.POST, url )
	}
	
	fileprivate func mergeDatas(_ datas: [String:Any]?, merge: inout [String:Any] ) {
		if let d = datas, d.count > 0 {
			merge.merge(d, uniquingKeysWith: {(current, _) -> Any in current })
		}
	}
	
	/**
	Adds headers to the request
	
	- parameter headers: A dictionary of headers to add to the request.
	
	- returns: The network request to be further built upon.
	*/
	public func addHeaders(_ headers: [String: Any]? ) -> NetworkRequest {
		mergeDatas(headers, merge: &self.headers)
		return self;
	}
	
	/**
	Adds params to the request

	- parameter params: A dictionary of params to be added to the request.
	
	- returns: The network request to be further built upon.
	*/
	public func addParams(_ params: [String: Any]? ) -> NetworkRequest {
		mergeDatas(params, merge: &self.params)
		return self;
	}
	
	func buildUrl() -> URL {
		let urlComponents = NSURLComponents( string: url )!
		
		if params.count > 0 && urlComponents.queryItems == nil {
			urlComponents.queryItems = []
		}
		
		for (k,v) in params {
			if let array = v as? [Any] {
				_ = array.map{
					urlComponents.queryItems?.append( URLQueryItem(name: k, value: String( describing:$0 ) ))
				}
			}
			else {
				urlComponents.queryItems?.append( URLQueryItem(name: k, value: String( describing:v )) )
			}
		}
		
		return urlComponents.url!
	}
	
	/**
	Executes the task asynchronously. Equivalent to execute(completionHandler: nil)
	*/
	public func execute()
	{
		execute(completionHandler: nil)
	}
	
	/**
	Once the request has been built execute should be called to actually execute the task asynchronously.
	
	- parameter completionHandler: The callback to be called once the response has been completed.
	*/
	public func execute( completionHandler: ((Data?, URLResponse?, Error?) -> Void)? )
	{
		var request = URLRequest(url: buildUrl())
		request.httpMethod = methodType.rawValue
		
		for (k,v) in headers {
			request.addValue(String( describing: v ), forHTTPHeaderField: k)
		}
		
		let configuration = URLSessionConfiguration.ephemeral
		let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
		
		var task: URLSessionDataTask
		if let ch = completionHandler {
			task = session.dataTask(with: request, completionHandler: ch)
		}else{
			task = session.dataTask(with: request)
		}
		
		task.resume()
	}
}



