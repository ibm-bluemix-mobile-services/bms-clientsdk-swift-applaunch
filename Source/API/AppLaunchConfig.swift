//
//  AppLaunchConfig.swift
//  AppLaunch
//
//  Created by Vittal Pai on 1/2/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 AppLaunchConfig contains configuration of AppLaunch Service which is used by `AppLaunch` APIs
 
 This method will intialize the AppLaunchConfig with the help of Builder Class. The builder class parameters are optional.
 
 - parameter cacheExpiration(Optional): Decides the time interval of the engagements should be valid for. On expiration time the actions are fetched from the server. This parameter has effect when the RefreshPolicy is set to RefreshPolicy.REFRESH_ON_EXPIRY or RefreshPolicy.BACKGROUND_REFRESH. The default value is 30 minutes.
 - parameter deviceID(Optional): used to override device ID. This parameter must be unique. If not specified, default deviceID generation mechanism is used by SDK.
 - parameter eventFlushInterval(Optional): Decides the time interval of the events which should be sent to the server. The default value is 30 minutes.
 - parameter fetchPolicy(Optional): This parameter decides on how frequently the engagements should be fetched from the server.
 
 */
public class AppLaunchConfig {
    
    private var policy: RefreshPolicy
    private var cacheExpiration: Float
    private var eventFlushInterval: Float
    private var deviceID: String
    private var ICRegion: String = String()
    private var appID: String = String()
    private var clientSecret: String = String()
    
    init(_ builder: Builder) {
        self.policy = builder.policy
        self.cacheExpiration = builder.cacheExpiration
        self.eventFlushInterval = builder.eventFlushInterval
        self.deviceID = builder.deviceID
    }
    
    /**
     Builder class of AppLaunchConfig
     */
    public class Builder {
        // default values
        internal var policy: RefreshPolicy = .REFRESH_ON_EVERY_START
        internal var deviceID: String = AppLaunchUtils.getDeviceID()
        internal var cacheExpiration: Float = 30
        internal var eventFlushInterval: Float = 30
        
        /**
         Initializer for builder class of AppLanchConfig
         */
        public init() {
            
        }
        
        /**
         This method can be used to set `RefreshPolicy` decides on how frequently the engagements should be fetched from the server. If not set, The default value will be `RefreshPolicy.REFRESH_ON_EVERY_START`.
         */
        public func fetchPolicy(_ policy: RefreshPolicy) -> Builder {
            self.policy = policy
            return self
        }
        
        /**
         This method can be used to set `cacheExpiration` time which decides the time interval of the engagements should be valid for. On expiration time the actions are fetched from the server. This parameter has effect when the RefreshPolicy is set to `RefreshPolicy.REFRESH_ON_EXPIRY` or `RefreshPolicy.BACKGROUND_REFRESH`. If not set, The default value will be 30 minutes.
         */
        public func cacheExpiration(_ cacheExpiration: Float) -> Builder {
            self.cacheExpiration = cacheExpiration
            return self
        }
        
        /**
         This method can be used to set `eventFlushInterval` time which decides the time interval of the events which should be sent to the server. If not set, The default value will be 30 minutes.
         */
        public func eventFlushInterval(_ eventFlushInterval: Float) -> Builder {
            self.eventFlushInterval = eventFlushInterval
            return self
        }
        
        /**
         This method can be used to set `deviceID` value which is used to override device ID. This parameter must be unique. If not specified, default deviceID generation mechanism is used by SDK.
         */
        public func deviceID(_ deviceID: String) -> Builder {
            self.deviceID = deviceID
            return self
        }
        
        /**
         This method builds AppLaunch Configuration object.
         
         - returns: `AppLaunchConfig` object
         */
        public func build() -> AppLaunchConfig {
            return AppLaunchConfig(self)
        }
        
    }
    
    internal func setICRegion(_ ICRegion: String) {
        self.ICRegion = ICRegion
    }
    
    internal func setAppID(_ appID: String) {
        self.appID = appID
    }
    
    internal func setClientSecret(_ clientSecret: String) {
        self.clientSecret = clientSecret
    }
    
    internal func getPolicy() -> RefreshPolicy {
        return policy
    }
    
    internal func getCacheExpiration() -> Float {
        return cacheExpiration
    }
    
    internal func getEventFlushInterval() -> Float {
        return eventFlushInterval
    }
    
    internal func getDeviceID() -> String {
        return deviceID
    }
    
    internal func getICRegion() -> String {
        return ICRegion
    }
    
    internal func getAppID() -> String {
        return appID
    }
    
    internal func getClientSecret() -> String {
        return clientSecret
    }
    
}






