# Empyr iOS Swift Library

[![CI Status](http://img.shields.io/travis/EmpyrNetwork/empyr_ios_swift.svg?style=flat)](https://travis-ci.org/EmpyrNetwork/empyr_ios_swift)
[![Version](https://img.shields.io/cocoapods/v/Empyr.svg?style=flat)](http://cocoapods.org/pods/Empyr)
[![License](https://img.shields.io/cocoapods/l/Empyr.svg?style=flat)](http://cocoapods.org/pods/Empyr)
[![Platform](https://img.shields.io/cocoapods/p/Empyr.svg?style=flat)](http://cocoapods.org/pods/Empyr)

Welcome to Empyr's iOS Library. This library is intended to help ease the integration effort for partners that participate in the Empyr Offer Platform.

## Compatibility
The Empyr iOS library is primarily developed in Swift and as such allows publishers who primarily develop in Swift a superset of functionality and extendability. That said, the main API functionalities are easily used across both **Objective-C AND Swift**.

## Features
The Empyr iOS library is currently designed to facilitate two different components of our platform

- **Tracker** -- The Tracker component is an easy way for publishers to send impression data to Empyr about their users viewing various offers. Additionally, this component provides Empyr with the data necessary to coordinate segmentation of those users which allows us to distribute more content to those users.
- **PPO** -- The PPO (Project Perfect Offer) component enables a publisher to seamlessly integrate recommendations about nearby deals for their users even when the publisher's application is in the background.

### Note
It should be noted that while both of the above features are available partners are not required to use **BOTH** of those functionalities.

<a name="installation"></a>
## Installation
We recommend using CocoaPods to integrate the Empyr SDK with your project.

```ruby
# Includes the core API
pod 'Empyr'

# Optionally include the additional functionality desired
# Please refer to the additional documentation about supporting these
# individual features below.
pod 'Empyr/PPO'
pod 'Empyr/Tracker'
```

> With Cocoapods 1.5 is is no longer necessary to 'use_frameworks!' with Swift pods as they can now be made static OR dynamic. 

<a name="integrate"></a>
## Integrate

To start the EmpyrAPIClient should be initialized in your AppDelegate.

**Swift**
```swift
import Empyr
...
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

	// Initialize Empyr API
	let empyrAPI = EmpyrAPIClient.initialize(clientId: "23d5f04e-424b-4751-b862-94cae1787c74")

	// Optional: Initialize Empyr PPO -- This MUST be done at application start.
	// If you are already using the UNNotificationCenter delegate then you 
	// should initialize that BEFORE initializing EmpyrPPO.
	EmpyrPPO.initialize(api: empyrAPI, launchOptions: launchOptions, askPermissions: true, delegate: self)
	
	return  true
}
```

**Objective-C**
```objectivec
@import Empyr;
...
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Initialize the Empyr API
	EmpyrAPIClient * empyrAPI = [EmpyrAPIClient  initializeWithClientId:@"23d5f04e-424b-4751-b862-94cae1787c74"];
	
	// Optional: Initialize Empyr PPO -- This MUST be done at application start.
	// If you are already using the UNNotificationCenter delegate then you 
	// should initialize that BEFORE initializing EmpyrPPO.
	[EmpyrPPO  initializeWithApi:empyrAPI launchOptions: launchOptions askPermissions:false delegate:self];
}

```

### Identify your users
If a user has signed up for Empyr offers then the user should be identified with the Empyr SDK library. This can be accomplished through the "identify" function call.

**Swift**
```swift
EmpyrAPIClient.mainInstance().identify(userToken: "pubid@pub-empyr.com")
```

**Objective-C**
```objectivec
[[EmpyrAPIClient  mainInstance] identifyWithUserToken: @"pubid@pub-empyr.com"];
```

## Tracker
> **WARNING** -- The Tracker component uses IDFA. You must add the AdSupport framework to your project. When submitting to the App Store you should disclose the use of the IDFA tracking to Apple or risk rejection.

When an offer is being viewed by a user the EmpyrAPI should be notified. The offerId would be the offer that is being viewed by the user and **IS NOT** the business id but the actual offer id. For any given business if there is more than one offer then this would result in more than one call to the track function. Additionally, it is important to identify the type of impression (e.g. if it was a "profile" view or a "search" view).

**Swift**
```swift
EmpyrAPIClient.mainInstance().track(offerId:1111, tracker: Tracker.PROFILE_VIEW)
```

**Objective-C**
```objectivec
[[EmpyrAPIClient  mainInstance] trackWithOfferId:1111 tracker:TrackerPROFILE_VIEW];
```

##

## PPO
The PPO component will monitor a users location relative to businesses on the Empyr platform. This will occur even if your app is in the background. When a user is detected to be within range of a business nearby it will determine if the user should be notified about the offer. If so, the user will see a notification prompting them to visit that location. If the user opens the notification a callback will be performed on a delegate that was supplied when initializing PPO allowing the host application to display any relevant business information/profile.

Enabling PPO requires the following:

- Add the "Empyr/PPO" submodule in your Podfile. See [Installation](#installation).
- Add the appropriate permissions to your application. See [Permissions](#permissions).
- Initialize the PPO library. See [Integrate](#integrate).
- Install a delegate to handle the case when a user opens an event. See [Delegate](#delegate).

<a name="permissions"></a>
### Permissions 
In order for Empyr PPO to be able to monitor the users location it is necessary to add the following keys to your PLIST.

- NSLocationAlwaysUsageDescription, 
- NSLocationAlwaysAndWhenInUseUsageDescription, 
- NSLocationWhenInUseUsageDescription

<a name="delegate"></a>
### Delegate
If you wish to handle the opening of the notifications from the Empyr PPO module then you would provide a delegate for those activities. For example, the following illustrates the Empyr PPO delegate installation.

**Swift**
```swift
class AppDelegate: UIResponder, UIApplicationDelegate, EmpyrNearbyBusinessOfferDelegate {
	func nearbyOfferNotification(business: RestBusiness) {
		print( "Business notification \(business.name)" )
	}
}
```

**Objective-C**
```objectivec
... (header)
@protocol  EmpyrNearbyBusinessOfferDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate, EmpyrNearbyBusinessOfferDelegate>

... (implementation)
#pragma mark - Empyr

- (void)nearbyOfferNotificationWithBusiness:(EMPBusiness *)business {
	NSLog( @"Business notification %@", business.name );
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Empyr Development, developer@empyr.com

## License

Empyr is available under the MIT license. See the LICENSE file for more info.
