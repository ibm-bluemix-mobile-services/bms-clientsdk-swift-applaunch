# bms-engage-ios-clientsdk

This is the Swift SDK for IBM Engage service.

>The Bluemix Engage service Engage service on Bluemix helps in controlled reach of app features. It provides a unified service to customize and personalize your applications to different audience with just few clicks.

Ensure that you go through [Bluemix Engage service documentation](https://console.ng.bluemix.net/docs/services/) before you start.

## Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Initialize SDK](#initialize-sdk)
	- [Include client Engage SDK](#include-client-engage-sdk)
	- [Initialize](#initialize)
- [Feature Toggle](#feature-toggle)
	- [Check if feature is enabled](#check-if-feature-is-enabled)
	- [Get variable for feature](#get-variable-for-feature)
- [Metrics](#metrics)
	- [Send Metrics](#send-metrics)
- [Samples and videos](#samples-and-videos)


## Prerequisites

- iOS 8.0+
- Xcode 7.3, 8.0
- Swift 2.3 - 3.0
- Cocoapods or Carthage

## Installation

The Bluemix Mobile Services Swift SDKs are available via [Cocoapods](http://cocoapods.org/) and [Carthage](https://github.com/Carthage/Carthage).

### Cocoapods
To install Engage using Cocoapods, add it to your Podfile:

```ruby
use_frameworks!

target 'MyApp' do
    platform :ios, '8.0'
    pod 'BMSCore', '~> 2.0'
    pod 'BMSEngage', '~> 3.0'
end
```
From the Terminal, go to your project folder and install the dependencies with the following command:

```
pod install
```

#### Swift 2.3

Before running the `pod install` command, make sure to use Cocoapods version [1.1.0.beta.1](https://github.com/CocoaPods/CocoaPods/releases/tag/1.1.0.beta.1).

#### Swift 3.0

Before running the `pod install` command, make sure to use Cocoapods version [1.1.0.beta.1](https://github.com/CocoaPods/CocoaPods/releases/tag/1.1.0.beta.1).

For apps built with Swift 3.0, you may receive a prompt saying "Convert to Current Swift Syntax?" when opening your project in Xcode 8 (following the installation of BMSCore) do not convert BMSEngage or BMSCore.

This will installs your dependencies and creates a new Xcode workspace.
***Note:*** Ensure that you always open the new Xcode workspace, instead of the original Xcode project file:

```
MyApp.xcworkspace
```

### Carthage
To install BMSEngage using Carthage, add it to your Cartfile:

```
github "ibm-bluemix-mobile-services/bms-clientsdk-swift-engage"
```

Then run the `carthage update` command. Once the build is finished, drag `BMSEngage.framework` and `BMSCore.framework` into your Xcode project.

To complete the integration, follow the instructions [here](https://github.com/Carthage/Carthage#getting-started).

#### Xcode 8

For apps built with Swift 2.3, use the command `carthage update --toolchain com.apple.dt.toolchain.Swift_2_3.` Otherwise, use `carthage update`


## Enabling iOS applications to use IBM Engage

### Reference the SDK in your code.

```
import BMSEngage
```
### Initializing the Engage SDK

```
Engage.sharedInstance.initializeWithAppGUID(applicationId: "your engage appGUID", clientSecret: "your engage client secret")
```

### Register the user

```
Engage.sharedInstance.registerWith(userId: "chethan")
```
Provide a completion handler to get a callback with the status and result of the call.

### Get features

```
Engage.sharedInstance.getFeatures
```

Provide a completion handler to get the status and response of the call.

### Utility methods to get features and its properties

* Use the ```Engage.sharedInstance.hasFeatureWith(code: "feature code")``` to check if the feature is enabled for the app.

* Use the ```Engage.sharedInstance.getPropertyValueFor(featureWithCode: "feature code", propertyWithCode: "property code")``` to get the value of the particular property in a feature.

### Metrics

To send metrics to the server use the ```Engage.sharedInstance.sendMetricsWith()``` api. This sends the metrics information to the server.

```
Engage.sharedInstance.sendMetricsWith(code: "metric code")
```
