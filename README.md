# bms-AppLaunch-ios-clientsdk

This is the Swift SDK for IBM App Launch service.

>The Bluemix App Launch service on Bluemix helps in controlled reach of app features. It provides a unified service to customize and personalize your applications to different audience with just few clicks.

Ensure that you go through [Bluemix App Launch service documentation](https://console-regional.ng.bluemix.net/docs/services/app-launch/index.html) before you start.

***

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
##Setup App Launch Service
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

### Cocoapods (full version coming soon)
To install AppLaunch using Cocoapods, add it to your Podfile:

```ruby
use_frameworks!

target 'MyApp' do
    platform :ios, '8.0'
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

#### Add AppLaunch framework

Drag and drop the downloaded AppLaunch.framework into your project.

Add the AppLaunch.framework into **Embedded Binaries** section.

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
import AppLaunch
```
### Initializing the AppLaunch SDK

```
AppLaunch.sharedInstance.initializeWithAppGUID(applicationId: "your AppLaunch appGUID", clientSecret: "your AppLaunch client secret",region: "region")

```

### Register the user

```
AppLaunch.sharedInstance.registerWith(userId: "chethan")
```
Provide a completion handler to get a callback with the status and result of the call.

### Get Client Actions

```
AppLaunch.sharedInstance.actions
```

Provide a completion handler to get the status and response of the call.

### Get features and its properties

* Use the ```AppLaunch.sharedInstance.hasFeatureWith(code: "feature code")``` to check if the feature is enabled for the app.

* Use the ```AppLaunch.sharedInstance.getPropertyValueFor(featureWithCode: "feature code", propertyWithCode: "property code")``` to get the value of the particular property in a feature.

### Metrics

To send metrics to the server use the ```AppLaunch.sharedInstance.sendMetricsWith()``` api. This sends the metrics information to the server.

```
AppLaunch.sharedInstance.sendMetricsWith(code: "metric code")
```
