//
//  EmpyrTracker.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 3/20/18.
//

import Foundation

/// The Tracker is the type of view
@objc public enum Tracker : Int {
	/// The impression occurred on a profile view.
	case PROFILE_VIEW
	/// The impression occurred on a search view.
	case SEARCH_VIEW
	
	func name() -> String {
		switch self {
		case .PROFILE_VIEW: return "PROFILE_VIEW"
		case .SEARCH_VIEW: return "SEARCH_VIEW"
		}
	}
}

struct TrackerConstants {
	static let TRACKER_URL = "https://t.mogl.com/t/t.png"
}

/// Singleton class that manages the Empyr tracking queue and flushes it regularly.
public class EmpyrTracker {
	/// Main EmpyrTracker singleton manages the event queue
	static var main : EmpyrTracker? = nil
	
	/// API client that will be used for flushing events.
	var empyrAPI: EmpyrAPIClient
	
	/// Flush every 60 seconds
	var flushInterval: Int = 60
	
	/// Timer for managing flushing the queue.
	var flushTimer : DispatchSourceTimer
	
	/// The queue that is used to synchronize the events for flushing.
	var flushQueue : DispatchQueue
	
	/// Keeps track of the events to flush in th next interval.
	var events : [Tracker:[Int]] = [:]
	
	/**
	Initializes the EmpyrTracker with the API for flushing.
	
	- parameter api:	The API that will ultimately be used for flushing.
	*/
	init(_ api: EmpyrAPIClient) {
		empyrAPI = api
		
		flushQueue = DispatchQueue(label: "com.empyr.tracker.flushqueue")
		
		flushTimer = DispatchSource.makeTimerSource(queue: flushQueue)
		flushTimer.schedule(deadline: .now(), repeating: .seconds(flushInterval))
		flushTimer.setEventHandler { [weak self] in
			self?.flush()
		}
		
		flushTimer.resume()
	}
	
	/**
	Terminates the EmpyrTracker and cleans it up. This should never technically
	be called on the singleton.
	*/
	deinit {
		flushTimer.cancel()
	}
	
	/**
	Returns the main instance of the EmpyrTracker and configures it with the provided
	EmpyrAPI. If one has already been created it will be returned.
	
	- parameter api: The API to initialize the tracker with. It will be used for making the network requests.
	
	- returns: Returns the main EmpyrTracker instance.
	*/
	class func mainInstance( api: EmpyrAPIClient ) -> EmpyrTracker
	{
		guard let m = main else {
			main = EmpyrTracker.init(api)
			return main!
		}
		
		return m
	}
	
	/**
	Adds an offer impression view to the tracking queue.
	
	- parameter offerId: The offer that was impressed by the user.
	- parameter tracker: The tracker indicates where the offer was viewed.
	
	- SeeAlso: Tracker
	*/
	@objc open func track( offerId: Int, tracker: Tracker ) {
		flushQueue.async {
			self.events[tracker] = self.events[tracker] ?? []
			self.events[tracker]?.append(offerId)
		}
	}
	
	/**
	Called to flush the event queue. Typically called internally on the
	flushInterval. Note that this is not synchronized to the dispatch queue
	without being called by the internal timer.
	*/
	func flush() {
		if events.count == 0 {
			return
		}
		
		// Basic parameter building including the app id, idfa, and usertoken when available.
		let req = NetworkRequest.get(url: TrackerConstants.TRACKER_URL)
			.addParams(["client_id": empyrAPI.clientId])
		
		if let token = empyrAPI.userToken {
			_ = req.addParams(["ut": token])
		}
		
		// Convert the events into data for the log
		for (k,v) in events {
			_ = req.addParams([k.name() : v.map{String($0)}.joined(separator: ",")])
		}
		
		// Clear the events queue since
		events.removeAll()
		
		req.execute()
	}
}

/// Extends the API client interface to include the track function.
extension EmpyrAPIClient {
	@objc open func track( offerId: Int, tracker: Tracker ) {
		EmpyrTracker.mainInstance(api: self).track(offerId: offerId, tracker: tracker)
	}
}
