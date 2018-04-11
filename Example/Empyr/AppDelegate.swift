//
//  AppDelegate.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 03/01/2018.
//  Copyright (c) 2018 Jarrod Cuzens. All rights reserved.
//

import UIKit
import Empyr

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, EmpyrNearbyBusinessOfferDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		let empyrAPI = EmpyrAPIClient.initialize(clientId: "23d5f04e-424b-4751-b862-94cae1787c74")
		_ = EmpyrPPO.initialize(api: empyrAPI, askPermissions: true, delegate: self)
		empyrAPI.identify(userToken: "2")
		empyrAPI.track(offerId: 1234, tracker: Tracker.PROFILE_VIEW)
		empyrAPI.track(offerId: 4567, tracker: Tracker.PROFILE_VIEW)
		empyrAPI.track(offerId: 0000, tracker: Tracker.SEARCH_VIEW)
		empyrAPI.track(offerId: 0001, tracker: Tracker.SEARCH_VIEW)
		
        // Override point for customization after application launch.
        return true
    }
	
	func nearbyOfferNotification(business: RestBusiness) {
		print( "Business notification \(business.name)" )
	}

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		EmpyrAPIClient.logToConsole(msg: "Background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		EmpyrAPIClient.logToConsole(msg: "Foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
		
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

