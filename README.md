# IBM Cloud Mobile Services - AppLaunch iOS Swift Client SDK

[![Build Status](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch.svg?branch=master)](https://travis-ci.org/ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch)
[![CocoaPods](https://img.shields.io/cocoapods/v/IBMAppLaunch.svg)](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch)

This is the Swift SDK for IBM App Launch service.

>The Bluemix App Launch service on Bluemix helps in controlled reach of app features. It provides a unified service to customize and personalize your applications to different audience with just few clicks.

Ensure that you go through [Bluemix App Launch service documentation](https://console-regional.ng.bluemix.net/docs/services/app-launch/index.html) before you start.

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
- [Initialize SDK](#initialize-sdk)
	- [Include client AppLaunch SDK](#include-client-appLaunch-sdk)
	- [Initialize](#initialize)
- [Feature Toggle](#feature-toggle)
	- [Check if feature is enabled](#check-if-feature-is-enabled)
	- [Get variable for feature](#get-variable-for-feature)
- [Metrics](#metrics)
	- [Send Metrics](#send-metrics)
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

The Bluemix Mobile Services Swift SDKs are available via [Cocoapods](http://cocoapods.org/) and [Carthage](https://github.com/Carthage/Carthage).

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

For apps built with Swift 3.2, you may receive a prompt saying "Convert to Current Swift Syntax?" when opening your project in Xcode 9 (following the installation of BMSCore) do not convert AppLaunch or BMSCore.

This will installs your dependencies and creates a new Xcode workspace.
***Note:*** Ensure that you always open the new Xcode workspace, instead of the original Xcode project file:

```
MyApp.xcworkspace
```
***

### Carthage (coming soon)
To install AppLaunch using Carthage, add it to your Cartfile:

```
github "ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch"
```

Then run the `carthage update` command. Once the build is finished, drag `AppLaunch.framework` and `BMSCore.framework` into your Xcode project.

To complete the integration, follow the instructions [here](https://github.com/Carthage/Carthage#getting-started).

***

## Enabling iOS applications to use IBM App Launch

### Reference the SDK in your code.

```
import IBMAppLaunch
```
### Initializing the AppLaunch SDK

##### 1. Build Configuration Object

```
let config =   AppLaunchConfig.Builder().cacheExpiration(30).eventFlushInterval(60).fetchPolicy(.REFRESH_ON_EXPIRY).build()
```

The AppLaunchConfig builder is used to customize the following:

- `eventFlushInterval` : Decides the time interval the events should be sent to the server. The default value is 30 minutes.

- `cacheExpiration` : Decides the time interval the actions should be valid for. On expiration time the actions are fetched from the server. This parameter has effect when the `RefreshPolicy` is set to `RefreshPolicy.REFRESH_ON_EXPIRY` or `RefreshPolicy.BACKGROUND_REFRESH`. The default value is 30 minutes.

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

`userId`: The user to be registered

`custom`: This can be used to pass any optional custom user attributes. 

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
     

### Get features and its properties

* Use the ```AppLaunch.sharedInstance.isFeatureEnabled(featureCode: "feature code")``` to check if the feature is enabled for the app.

* Use the ```AppLaunch.sharedInstance.getPropertyofFeature(featureCode: "feature code", propertyCode: "property code")``` to get the value of the particular property in a feature.


 **Note** :The above two APIs throws `applaunchNotIntialized` error if `isFeatureEnabled` or `getPropertyofFeature` is invoked before `initialize` API.  

### Metrics

To send metrics to the server use the ```AppLaunch.sharedInstance.sendMetrics()``` API. This API call sends the metrics information to the server.

```
AppLaunch.sharedInstance.sendMetrics(code: ["metricCodes"])
```

 **Note** : The above API throws `applaunchNotIntialized` error if `sendMetrics` is invoked before `initialize` API.

### Destroy

This method unregisters the user from AppLaunch Service and clears the cache

```
AppLaunch.sharedInstance.destroy(completionHandler: AppLaunchCompletionHandler)
```

### Samples and Videos

* For samples, visit - [Github Sample](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-applaunch)


### Learn More

* Visit the **[IBM Cloud Developers Community](https://developer.ibm.com/bluemix/)**.

### Connect with Bluemix

[Twitter](https://twitter.com/ibmbluemix)|
[YouTube](https://www.youtube.com/watch?v=dQ1WcY_Ill4) |
[Blog](https://developer.ibm.com/bluemix/blog/) |
[Facebook](https://www.facebook.com/ibmbluemix) |
[Meetup](http://www.meetup.com/bluemix/)

