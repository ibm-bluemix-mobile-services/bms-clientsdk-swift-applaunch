# IBM Cloud Mobile Services - AppLaunch iOS Swift Client SDK

[![Build Status](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch.svg?branch=master)](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch)
[![CocoaPods](https://img.shields.io/cocoapods/v/IBMAppLaunch.svg)](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch)

This Swift SDK for App Launch on IBM Cloud services, provides a library for developers to build mobile applications on iOS devices.

>App Launch on IBM Cloud services enables the developers to build engaging apps by controlling reach and roll out of App features while measuring the defined metrics.

Ensure that you go through [IBM Cloud App Launch service documentation](https://console-regional.ng.bluemix.net/docs/services/app-launch/index.html) before you start.

***

## Build Status

| Master | Development |
|:------:|:-----------:|
|  [![Build Status](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch.svg?branch=master)](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch)      |    [![Build Status](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch.svg?branch=development)](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch)         |

## Contents
- [Setup App Launch Service](#setup-app-launch-service)
	 - [Creating the service](#creating-the-service)
	 - [Creating a feature](#creating-a-feature)
	 - [Creating an audience](#creating-an-audience)
	 - [Creating an engagement](#creating-an-engagement)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Enabling iOS applications to use IBM App Launch](#enabling-ios-applications-to-use-ibm-app-launch)
	- [Import the App launch SDK in your code](#import-the-app-launch-sdk-in-your-code)
	- [Initializing the AppLaunch SDK](#initializing-the-appLaunch-sdk)
- [Feature Toggle](#feature-toggle)
	- [Check if feature is enabled](#feature-toggle)
	- [Get variable for feature](#feature-toggle)
- [Metrics](#metrics)
	- [Send Metrics](#send-metrics)
- [InApp Messages](#inapp-messages)
    - [Display InApp Messages](#display-inappmessages) 
- [Destroy](#destroy)
- [Samples and videos](#samples-and-videos)

***

## Setup App Launch Service

### Creating the service
![Create feature](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-android-applaunch/blob/development/Images/create_service.gif)
### Creating a feature
![Create feature](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-android-applaunch/blob/development/Images/create_feature.gif)
### Creating an audience
![Create audience](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-android-applaunch/blob/development/Images/create_audience.gif)
### Creating an engagement
![Create engagement](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-android-applaunch/blob/development/Images/create_engagement.gif)

## Prerequisites

- iOS 10+
- Xcode 9
- Swift 3.2 - 4
- Cocoapods or Carthage

***

## Installation

The Swift SDKs for IBM Cloud Mobile services are available via [Cocoapods](http://cocoapods.org/) and [Carthage](https://github.com/Carthage/Carthage).

### Cocoapods
To install AppLaunch using Cocoapods, add it to your Podfile:

```ruby
use_frameworks!

target 'MyApp' do
    platform :ios, '9.0'
    pod 'IBMAppLaunch'
    pod 'BMSCore', '~> 2.0'
    pod 'SwiftyJSON'
end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end
```
From the Terminal, go to your project folder and install the dependencies with the following command:

```
pod install
```



#### Swift 3.2

Before running the `pod install` command, make sure to use Cocoapods version [1.1.0.beta.1](https://github.com/CocoaPods/CocoaPods/releases/tag/1.1.0.beta.1).

Apps built with Swift 3.2 may receive a message "Convert to Current Swift Syntax?" while opening the project on Xcode 9, make sure you do not convert AppLaunch or BMSCore.

This will installs your dependencies and creates a new Xcode workspace.
***Note:*** Always open a new Xcode workspace instead of the existing xcode project file:

```
MyApp.xcworkspace
```
***

### Carthage (coming soon)
Add AppLaunch to your Cartfile in order to install using Carthage.

```
github "ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch"
```

Run the carthage update command. Once built, drag `AppLaunch.framework` and `BMSCore.framework` into your Xcode project.

To complete the integration, follow the instructions [here](https://github.com/Carthage/Carthage#getting-started).

***

## Enabling iOS applications to use IBM App Launch

### Import the App launch SDK in your code.

```
import IBMAppLaunch
```
### Initializing the AppLaunch SDK

##### 1. Build Configuration Object

```
let config =   AppLaunchConfig.Builder().cacheExpiration(30).eventFlushInterval(60).fetchPolicy(.REFRESH_ON_EXPIRY).build()
```

The AppLaunchConfig builder is used to customize the following:

- `eventFlushInterval` : Sets/Decide the time interval on when the events should be sent to the server. The default value is 30 minutes.

- `cacheExpiration` : Sets/Decide the time interval until when the actions should be valid for. The default value is 30 minutes.

	**Note** : This parameter is effective only if the `fetchPolicy` is set to `RefreshPolicy.REFRESH_ON_EXPIRY` or `RefreshPolicy.BACKGROUND_REFRESH`. 

- `fetchPolicy` : This parameter decides on how frequently the actions should be fetched from the server. The values can be one of the following:

 	-`RefreshPolicy.REFRESH_ON_EVERY_START`
  
  	-`RefreshPolicy.REFRESH_ON_EXPIRY`
 
  	-`RefreshPolicy.BACKGROUND_REFRESH`

	The default value is `RefreshPolicy.REFRESH_ON_EVERY_START`.
  	
- `deviceId`: This parameter must be unique. If not specified, default deviceID generation mechanism is used by SDK.
 
	**Note**: Do not rely on the default implementation of the deviceID generation  mechanism as it is not guarenteed to be unique.

##### 2. Build User Object

```
let user = AppLaunchUser.Builder(userId: "vittal").custom(key: "email", value: "vittalpai@xyz.com").build()
```

The AppLaunchUser builder is used to provide the following information:

- `userId`: The user to be registered

- `custom`: This can be used to pass any optional custom user attributes. 

##### 3. Initialize App Launch SDK

```
AppLaunch.sharedInstance.initialize(region: .US_SOUTH, appId: "appGUID", clientSecret: "clientSecret", config: AppLaunchConfig, user: AppLaunchUser, completionHandler: AppLaunchCompletionHandler)
```

Where `region` parameter specifies the location where the app is hosted. You can use any of the following values:

- `ICRegion.US_SOUTH`
- `ICRegion.UNITED_KINGDOM`
- `ICRegion.SYDNEY`
- `ICRegion.US_SOUTH_STAGING`
- `ICRegion.UNITED_KINGDOM_STAGING`

The `appGUID` is the app launch app GUID value, while `clientSecret` is the appLaunch client secret value which can be obtained from the service console.

`AppLaunchCompletionHandler` is the completion handler which will be used to notify in case of success and failure events.
     

### Feature Toggle

* Use the ```AppLaunch.sharedInstance.isFeatureEnabled(featureCode: "feature code")``` to check if the feature is enabled for the app.

* Use the ```AppLaunch.sharedInstance.getPropertyofFeature(featureCode: "feature code", propertyCode: "property code")``` to get the value of the particular property in a feature.


 **Note** :The above two APIs throws `applaunchNotIntialized` error if `isFeatureEnabled` or `getPropertyofFeature` is invoked before `initialize` API.  

### Metrics

To send metrics to the server use the ```AppLaunch.sharedInstance.sendMetrics()``` API. This API call sends the metrics information to the server.

```
AppLaunch.sharedInstance.sendMetrics(code: ["metricCodes"])
```

 **Note** : The above API throws `applaunchNotIntialized` error if `sendMetrics` is invoked before `initialize` API.
 
### InApp Messages

To display InApp messages invoke the following API.

```
 AppLaunch.sharedInstance.displayInAppMessages()
```

### Destroy

This method unregisters the user from AppLaunch Service and clears the cache

```
AppLaunch.sharedInstance.destroy(completionHandler: AppLaunchCompletionHandler)
```

### Samples and Videos

* For samples, visit - [Github Sample](https://github.com/ibm-bluemix-mobile-services/bms-samples-swift-helloapplaunch)


### Learn More

* Visit the **[IBM Cloud Developers Community](https://developer.ibm.com/bluemix/)**.

### Connect with IBM Cloud

[Twitter](https://twitter.com/ibmbluemix)|
[YouTube](https://www.youtube.com/watch?v=dQ1WcY_Ill4) |
[Blog](https://developer.ibm.com/bluemix/blog/) |
[Facebook](https://www.facebook.com/ibmbluemix) |
[Meetup](http://www.meetup.com/bluemix/)