/*
*     Copyright 2016 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/


import BMSCore
import BMSAnalyticsAPI
import CoreLocation



// MARK: - Swift 3


    


/**
    Adds the `initialize` and `send` methods.
*/
internal extension Analytics {
    
    
    internal static var automaticallyRecordUsers: Bool = true
    
    
    
    /**
        The required initializer for the `Analytics` class when communicating with a Mobile Analytics service.
     
        Here you can choose what data you want to have monitored by `Analytics`, including user identities, user location, app lifecycle events, and network requests.

        - Note: This method must be called after initializing `BMSClient` with `BMSClient.sharedInstance.initialize(bluemixRegion:)` from the `BMSCore` framework, and before calling `send(completionHandler:)` or `Logger.send(completionHandler:)`.

        - parameter appName:            The application name.  Should be consistent across platforms (i.e. Android and iOS).
        - parameter clientSecret:             A unique ID used to authenticate with the Mobile Analytics service.
        - parameter hasUserContext:     If `false`, user identities will be automatically recorded using
                                            the device on which the app is installed. If you want to define user identities yourself using `Analytics.userIdentity`, set this parameter to `true`.
        - parameter collectLocation:    Determines whether Analytics should automatically monitor the user's
                                            current location. Before location can be retrieved, you must first request permission from the user with `CLLocationManager` `requestWhenInUseAuthorization()`.
        - parameter deviceEvents:       Device events that will be recorded automatically by the `Analytics` class.
    */
    internal static func initialize(config: AppLaunchConfig,url: String, hasUserContext: Bool = false, collectLocation: Bool = false, deviceEvents: DeviceEvent...) {
        
        AppLaunchAnalytics.appID = config.getAppID()
        AppLaunchAnalytics.deviceID = config.getDeviceID()
        AppLaunchAnalytics.url = url
        AppLaunchAnalytics.clientSecret = config.getClientSecret()
        
        
        // Link the BMSAnalytics implementation to the APIs in BMSAnalyticsAPI
        Logger.delegate = AppLaunchLogger()
        Analytics.delegate = AppLaunchAnalytics()
        
        Analytics.automaticallyRecordUsers = !hasUserContext
        // If the developer does not want to specify the user identities themselves, we do it for them.
        if automaticallyRecordUsers {
            // We associate each unique device with one unique user. As such, all users will be anonymous.
            Analytics.userIdentity = AppLaunchAnalytics.uniqueDeviceId
        }
        
        AppLaunchAnalytics.locationEnabled = collectLocation
        
        // Registering device events
        for event in deviceEvents {
            switch event {
            case .lifecycle:
                #if os(iOS)
                    AppLaunchAnalytics.startRecordingApplicationLifecycle()
                #else
                    Analytics.logger.warn(message: "The Analytics class cannot automatically record lifecycle events for non-iOS apps.")
                #endif
            case .network:
                BMSURLSession.shouldRecordNetworkMetadata = true
            }
        }
        
        AppLaunchLogger.startCapturingUncaughtExceptions()
        
        // Package analytics metadata in a header for each request
        // Outbound request metadata is identical for all requests made on the same device from the same app
        if BMSClient.sharedInstance.bluemixRegion != nil {
            Request.requestAnalyticsData = AppLaunchAnalytics.generateOutboundRequestMetadata()
        }
        else {
            Analytics.logger.warn(message: "Make sure that the BMSClient class has been initialized before calling the Analytics initializer.")
        }
    }
    
    
    /**
        Log the user's current location once. 
     
        - important: Before calling this method, make sure that you have requested permission to use location services from the user (using `CLLocationManager` `requestWhenInUseAuthorization()`), and set the `collectLocation` parameter to `true` in the `Analytics.initialize(appName:clientSecret:hasUserContext:collectLocation:deviceEvents:)` method.
    */
    internal static func logLocation() {
        
        AppLaunchAnalytics.logEvent(Constants.Metadata.Analytics.location)
    }
    
    
    /**
        Send the accumulated analytics logs to the Mobile Analytics service.

        Analytics logs can only be sent if the BMSClient was initialized with `BMSClient.sharedInstance.initialize(bluemixRegion:)` from the `BMSCore` framework.

        - parameter completionHandler:  Optional callback containing the results of the send request.
    */
    internal static func send(completionHandler userCallback: BMSCompletionHandler? = nil) {
        
        Logger.sendAnalytics(completionHandler: userCallback)
    }
    
}



// MARK: -

/*
    Provides the internal implementation of the `Logger` class in the BMSAnalyticsAPI framework.
*/
internal class AppLaunchAnalytics: AnalyticsDelegate {
    
    
    // MARK: Properties (public)
    
    // The name of the iOS/WatchOS app.
    internal fileprivate(set) static var appID: String?
    
    internal fileprivate(set) static var deviceID: String?
    
    internal fileprivate(set) static var url: String?
    
    // The unique ID used to send logs to the Mobile Analytics service.
    internal fileprivate(set) static var clientSecret: String?
    
    // Identifies the current application user.
    // To reset the userId, set the value to nil.
    internal var userIdentity: String? {
        
        // Note: The developer sets this value via Analytics.userIdentity
        didSet {
            
            // userIdentity is being set by the SDK
            if userIdentity == AppLaunchAnalytics.uniqueDeviceId {
                AppLaunchAnalytics.logEvent(Constants.Metadata.Analytics.user)
            }
            // userIdentity is being set by the developer
            else {
                guard !Analytics.automaticallyRecordUsers else {
                    
                    Analytics.logger.error(message: "Before setting the userIdentity property, you must first set the hasUserContext parameter to true in the Analytics initializer.")
                    
                    userIdentity = AppLaunchAnalytics.uniqueDeviceId
                    return
                }
                
                if AppLaunchAnalytics.lifecycleEvents[Constants.Metadata.Analytics.sessionId] != nil {
                    
                    AppLaunchAnalytics.logEvent(Constants.Metadata.Analytics.user)
                }
                else {
                    Analytics.logger.error(message: "To see active users in the analytics console, you must either opt in for DeviceEvents.LIFECYCLE in the Analytics initializer (for iOS apps) or first call Analytics.recordApplicationDidBecomeActive() before setting Analytics.userIdentity (for watchOS apps).")
                    
                    userIdentity = nil
                }
            }
        }
    }
    

    // MARK: Properties (internal)
    
    // Stores metadata (including a duration timer) for each app session
    // An app session is roughly defined as the time during which an app is being used (from becoming active to going inactive)
    internal static var lifecycleEvents: [String: Any] = [:]
    
    // The timestamp for when the current session started
    internal static var startTime: Int64 = 0
    
    internal static var sdkVersion: String {

        if let bundle = Bundle(identifier: "com.ibm.mobilefirstplatform.clientsdk.swift.BMSAnalytics") {
            return bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        }
        return ""
    }
    
    // Allows the developer to choose whether we should record location information for their users
    internal static var locationEnabled = false
    
    // The manager and delegate that get the user's current location to log as metadata
    internal static var locationManager = CLLocationManager()
    internal static var locationDelegate = LocationDelegate()
    
    
    
    // MARK: - App sessions
    
    // Log that the app is starting a new session, and start a timer to record the session duration
    // This method should be called when the app starts up.
    //      In iOS, this occurs when the app is about to enter the foreground.
    //      In watchOS, the user decides when this method is executed, but we recommend calling it when the app becomes active.
    @objc dynamic static internal func logSessionStart() {
        
        // If this method is called before logSessionEnd() gets called, exit early so that the original startTime and metadata from the previous session start do not get discarded.
            
        guard lifecycleEvents.isEmpty else {
            Analytics.logger.info(message: "A new session is starting before previous session ended. Data for this new session will be discarded.")
            return
        }
        
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
      
        AppLaunchAnalytics.startTime = Int64(Date.timeIntervalSinceReferenceDate * 1000) // milliseconds
        
        lifecycleEvents[Constants.Metadata.Analytics.sessionId] = UUID().uuidString
        lifecycleEvents[Constants.Metadata.Analytics.category] = Constants.Metadata.Analytics.appSession
        
        Analytics.log(metadata: lifecycleEvents)
        
        AppLaunchAnalytics.logEvent(Constants.Metadata.Analytics.initialContext)
    }
    
    
    // Log that the app session is ending, and use the timer from logSessionStart() to record the duration of this session
    // This method should be called when the app closes.
    //      In iOS, this occurs when the app enters the background.
    //      In watchOS, the user decides when this method is executed, but we recommend calling it when the app becomes active.
    @objc dynamic static internal func logSessionEnd() {
        
        // If logSessionStart() has not been called yet, the app session is ending before it starts.
        //      This may occur if the app crashes while launching. In this case, set the session duration to 0.
        var sessionDuration: Int64 = 0
        if !lifecycleEvents.isEmpty && AppLaunchAnalytics.startTime > 0 {
            sessionDuration = Int64(NSDate.timeIntervalSinceReferenceDate * 1000) - AppLaunchAnalytics.startTime
        }
        
        lifecycleEvents[Constants.Metadata.Analytics.category] = Constants.Metadata.Analytics.appSession
        
        lifecycleEvents[Constants.Metadata.Analytics.duration] = Int(sessionDuration)
        
        // Let the Analytics service know how the app was last closed
        if AppLaunchLogger.exceptionHasBeenCalled {
            lifecycleEvents[Constants.Metadata.Analytics.closedBy] = AppClosedBy.crash.rawValue
            Logger.isUncaughtExceptionDetected = true
        }
        else {
            lifecycleEvents[Constants.Metadata.Analytics.closedBy] = AppClosedBy.user.rawValue
            Logger.isUncaughtExceptionDetected = false
        }
        
        Analytics.log(metadata: lifecycleEvents)
        lifecycleEvents = [:]
        AppLaunchAnalytics.startTime = 0
    }
    
    
    // Remove the observers registered in the Analytics+iOS "startRecordingApplicationLifecycleEvents" method
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    // MARK: - Request analytics
    
    // Create a JSON string containing device/app data for the Analytics server to use
    // This data gets added to a Request header
    internal static func generateOutboundRequestMetadata() -> String? {
        
        // All of this data will go in a header for the request
        var requestMetadata: [String: String] = [:]
        
        // Device info
        var osVersion = "", model = "", deviceId = ""
        
        #if os(iOS)
            (osVersion, model, deviceId) = AppLaunchAnalytics.getiOSDeviceInfo()
            requestMetadata["os"] = "iOS"
        #elseif os(watchOS)
            (osVersion, model, deviceId) = AppLaunchAnalytics.getWatchOSDeviceInfo()
            requestMetadata["os"] = "watchOS"
        #endif

        requestMetadata["brand"] = "Apple"
        requestMetadata["osVersion"] = osVersion
        requestMetadata["model"] = model
        requestMetadata["deviceID"] = deviceId
        requestMetadata["mfpAppName"] = AppLaunchAnalytics.appID
        requestMetadata["appStoreLabel"] = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        requestMetadata["appStoreId"] = Bundle.main.bundleIdentifier ?? ""
        requestMetadata["appVersionCode"] = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
        requestMetadata["appVersionDisplay"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        requestMetadata["sdkVersion"] = sdkVersion
        
        var requestMetadataString: String?

        do {
            let requestMetadataJson = try JSONSerialization.data(withJSONObject: requestMetadata, options: [])
            requestMetadataString = String(data: requestMetadataJson, encoding: .utf8)
        }
        catch let error {
            Analytics.logger.error(message: "Failed to append analytics metadata to request. Error: \(error)")
        }
        
        return requestMetadataString
    }
    
    

    // MARK: - Helpers
    
    // Used to log certain events like initial context (when the app enters foreground), switching users, and getting user location
    internal static func logEvent(_ category: String) {
        
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000.0)
        
        var metadata: [String: Any] = [:]
        metadata[Constants.Metadata.Analytics.category] = category
        metadata[Constants.Metadata.Analytics.userId] = Analytics.userIdentity
        metadata[Constants.Metadata.Analytics.sessionId] = AppLaunchAnalytics.lifecycleEvents[Constants.Metadata.Analytics.sessionId]
        metadata[Constants.Metadata.Analytics.timestamp] = NSNumber(value: currentTime)
        
        // Get current location, add it to the metadata, and log
        if AppLaunchAnalytics.locationEnabled {
            if CLLocationManager.locationServicesEnabled() &&
                (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                    CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
                
                locationDelegate.analyticsMetadata = metadata
                locationManager.delegate = locationDelegate
                locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                
                
                if #available(iOS 9.0, *) {
                    locationManager.requestLocation()
                }
                else {
                    locationManager.startUpdatingLocation()
                }
            }
            else {
                Analytics.logger.warn(message: "The CLLocationManager authorization status must be authorizedWhenInUse before location data can be gathered.")
            }
        }
        else {
            Analytics.log(metadata: metadata)
        }
    }
    
    
    // Retrieve the unique device ID, or return "unknown" if it is unattainable.
    internal static func getDeviceId(from uniqueDeviceId: String?) -> String {
        
        if let id = uniqueDeviceId {
            return id
        }
        else {
            Analytics.logger.warn(message: "Cannot determine the unique ID for this device, so the recorded analytics data will not include it.")
            
            return "unknown"
        }
    }
}


// How the last app session ended
private enum AppClosedBy: String {
    
    case user = "USER"
    case crash = "CRASH"
}



// MARK: -

// For unit testing only
internal extension AppLaunchAnalytics {
    
    internal static func uninitialize() {
        Analytics.delegate = nil
        AppLaunchAnalytics.clientSecret = nil
        AppLaunchAnalytics.appID = nil
        NSSetUncaughtExceptionHandler(nil)
    }
}

    

    
    
/**************************************************************************************************/



internal extension AppLaunchAnalytics {
    
    // The device ID for iOS devices, unique to each bundle ID on each device.
    // Apps installed with different bundle IDs on the same device will receive different device IDs.
    internal static let uniqueDeviceId: String? = UIDevice.current.identifierForVendor?.uuidString
    
    // Records the duration of the app's lifecycle from when it enters the foreground to when it goes to the background.
    internal static func startRecordingApplicationLifecycle() {
        
        // By now, the app will have already passed the "will enter foreground" event. Therefore, we must manually start the timer for the current session.
        logSessionStart()
        
        NotificationCenter.default.addObserver(self, selector: #selector(logSessionStart), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logSessionEnd), name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    
    // General information about the device that the app is running on.
    // This data gets sent in every network request to the Analytics server
    internal static func getiOSDeviceInfo() -> (String, String, String) {
        
        var osVersion = "", model = "", deviceId = ""
        
        let device = UIDevice.current
        osVersion = device.systemVersion
        model = device.modelName
        deviceId = AppLaunchAnalytics.getDeviceId(from: AppLaunchAnalytics.uniqueDeviceId)
        
        return (osVersion, model, deviceId)
    }
    
}



// MARK: -

// Get the device type as a human-readable string
// http://stackoverflow.com/questions/26028918/ios-how-to-determine-iphone-model-in-swift
internal extension UIDevice {
    
    var modelName: String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":       return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                   return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                   return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                   return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":  return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":            return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":            return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":            return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":            return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":            return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":            return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                       return identifier
        }
    }
}





/**************************************************************************************************/




    
