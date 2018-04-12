//
//  EmpyrPPO.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 3/12/18.
//

import Foundation
import PlotProjects

/// Used by Empyr to inform the application when users are nearby offers.
/// Should be registered with the EmpyrPPO module at initialization.
@objc public protocol EmpyrNearbyBusinessOfferDelegate: class {
	/**
	Called when a notification about a nearby offer has been opened
	by the consumer.
	
	- parameter business: The business that the user was notified about.
	*/
	func nearbyOfferNotification( business: RestBusiness )
}

/// Empyr Project Perfect Offer client interface.
/// This class is responible for behaviors around
/// Project Perfect Offer.
public class EmpyrPPO: NSObject, PlotDelegate {
	#if DEBUG
		static let PLOT_KEY = "Tjbawm4kFd6XuE63"
		typealias Plots = PlotDebug
	#else
		static let PLOT_KEY = "AsD64TkND2bVJnUE"
		typealias Plots = PlotRelease
	#endif
	static let EMPYR_BUS_KEY = "EMPYR_BUS";
	
	static var instance: EmpyrPPO? = nil
	var api: EmpyrAPIClient
	var tokenObservation: NSKeyValueObservation
	var askPermissions: Bool
	weak var delegate: EmpyrNearbyBusinessOfferDelegate?
	
	// MARK: - Initializers
	private init( api: EmpyrAPIClient, launchOptions: [UIApplicationLaunchOptionsKey: Any]?, askPermissions:Bool = false, delegate: EmpyrNearbyBusinessOfferDelegate? = nil ){
		self.api = api
		self.askPermissions = askPermissions
		self.delegate = delegate;
		
		// Signals to turn on the Plot tracking for the user.
		tokenObservation = api.observe(\EmpyrAPIClient.userToken) { _, change in
			Plots.enable()
			Plots.setStringSegmentationProperty(api.clientId, forKey: "application")
			print( "PPO enabled" )
		}
		
		super.init()
		
		Plots.initialize(launchOptions: launchOptions, delegate: self)
		
		if askPermissions {
			if #available(iOS 10, *) {
				//Notifications get posted to the function (delegate):  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void)"
				UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
				}
			}
			else {
				let application = UIApplication.shared;
				let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
				application.registerUserNotificationSettings(settings)
			}
		}
		
		print( "PPO initialized" )
	}
	
	/**
	Initializes the Empyr Project Perfect Offer platform to enable monitoring of
	user location to determine when to notify them of relevant nearby offers.
	
	If your system requests permission for background location and notifications then
	askPermissions should be set to false to avoid EmpyrPPO attempting to ask for them.
	
	- warning: In case you need to register your own UNUserNotificationCenter delegate, you need to do that
	before initializing the plugin so that the EmpyrPPO plugin works and will forward any messages that
	are not created by EmpyrPPO to the parent delegate.
	
	- parameter api: The EmpyrAPIClient that the EmpyrPPO will interact with for looking at user recommendations.
	- parameter launchOptions: The application launch options. This is necessary for detecting large location changes in the background.
	- parameter askPermissions: Whether the PPO platform should ask permissions automatically on startup for Local Notifications and Background Location Services.
	If askPermissions is false then you MUST request these permissions in your own app before EmpyrPPO will work.
	- parameter delegate: Optional. When specified this delegate is called when a notfication is opened.
	
	- returns: A configured EmpyrPPO instance. Typically, not interacted with.
	*/
	@objc @discardableResult public static func initialize( api: EmpyrAPIClient, launchOptions: [UIApplicationLaunchOptionsKey: Any]?, askPermissions:Bool = false, delegate: EmpyrNearbyBusinessOfferDelegate? = nil ) -> EmpyrPPO? {
		
		guard let infoPlist = Bundle.main.infoDictionary,
			infoPlist["NSLocationAlwaysUsageDescription"] as? String != nil,
			infoPlist["NSLocationAlwaysAndWhenInUseUsageDescription" ] as? String != nil,
			infoPlist["NSLocationWhenInUseUsageDescription" ] as? String != nil
		else {
			print( "Warning: You did not supply keys NSLocationAlwaysUsageDescription, NSLocationAlwaysAndWhenInUseUsageDescription, NSLocationWhenInUseUsageDescription in the Info.plist file explaining why your app needs access to the location services. EmpyrPPO will not function without this setting." )
			return nil
		}
		
		instance = EmpyrPPO( api: api, launchOptions: launchOptions, askPermissions: askPermissions, delegate: delegate )
		return instance
	}
	
	// MARK: - Plot Delegate Methods
	public func plotLoadConfig(_ originalConfig: PlotConfiguration!, loadWithConfig: ((PlotConfiguration?) -> Void)!) {
		originalConfig.publicToken = EmpyrPPO.PLOT_KEY
		originalConfig.enableOnFirstRun = false
		originalConfig.automaticallyAskLocationPermission = askPermissions
		originalConfig.automaticallyAskNotificationPermission = askPermissions
		
		loadWithConfig(originalConfig)
		print( "PPO Config loaded" )
	}
	
	@available(iOS 10.0, *)
	public func plotHandleNotification(_ data: String!, response: UNNotificationResponse!) {
		guard let d = delegate, let data = response.notification.request.content.userInfo[EmpyrPPO.EMPYR_BUS_KEY] as? Data else {
			return;
		}
		
		do{
			let b = try JSONDecoder().decode(RestBusiness.self, from: data)
			d.nearbyOfferNotification(business: b)
		}catch {
			print( "Error deserializing business \(error)" )
		}
	}
	
	public func plotFilterNotifications(_ filterNotifications: PlotFilterNotifications!) {
		guard #available(iOS 10.0, *) else {
			return
		}
		
		// Build a map of business ids to notification pairs
		var businesses: [Int:UNNotificationRequest] = [:]
		var test = ""
		
		// Go through the notifications and decode the Empyr plot data.
		// This will be used to build the list of businesses nearby that
		// will be checked to see if they are in the user's recommended list.
		for n in filterNotifications.uiNotifications {
			if let d = n.content.userInfo[PlotNotificationDataKey] as? String {
				do {
					let empyrPlotData = try JSONDecoder().decode(EmpyrPlotData.self, from: d.data(using: .utf8)!)
					test = empyrPlotData.test
					businesses[empyrPlotData.businessId] = n
				}catch{
					print( "Malformed plot data \(d)")
				}
			}
		}
		
		// If we have businesses we should check them agains the API.
		if businesses.count > 0 {
			// If any of the keys (businessIds) were a match for
			// recommendations then show the corresponding recommendation.
			api.checkRecommendations(Array(businesses.keys), test:test) { (b : RestBusiness?) in
				guard let rb = b, let n = businesses[rb.id], let firstOffer = rb.offers.first else {
					// Business not recommended or a problem connecting to the API.
					// disregard the notification.
					filterNotifications.show([])
					return
				}
				
				let rewardText = firstOffer.getActiveReward();
				let content = UNMutableNotificationContent();
				
				do {
					content.body = n.content.body.replacingOccurrences(of: "#cashback", with: rewardText);
					content.userInfo.merge(n.content.userInfo) {(current, _) -> Any in current }
					content.userInfo[EmpyrPPO.EMPYR_BUS_KEY] = try JSONEncoder().encode( rb );
				}catch {
					print( "Error \(error)" )
				}
				
				let request = UNNotificationRequest( identifier: n.identifier, content: content, trigger: n.trigger )
				
				// The notification should be shown.
				filterNotifications.show([request])
			}
		}else{
			// We always call the filterNotifications.show() to ensure that
			// the notifications are "consumed"
			filterNotifications.show([])
		}
	}
}

struct EmpyrPlotData: Codable {
	let businessId: Int;
	let test: String;
}

/// Extends the EmpyrAPIClient with a method to check the recommendations of the
/// user.
extension EmpyrAPIClient {
	func checkRecommendations(_ businessIds: [Int], test: String, completion: @escaping (RestBusiness?) -> Void) {
		print( "Get recommendations for \(self.userToken!)" )
		
		get(url: "/users/\(self.userToken!)/recommendations", params:["businesses": businessIds, "test": test], expects: ["results": RestResults<RestBusiness>.self]) {
			( resp: RestResponse<RestResults<RestBusiness>>?, err: Error? ) in
			guard let r = resp, let results = r.response?.results, results.count > 0 else {
				completion(nil)
				return
			}
			completion(results[0])
		}
	}
}
