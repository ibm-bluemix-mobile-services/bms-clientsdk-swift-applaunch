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
 AppLaunchConfig contains configuration of AppLaunch Service which is used by AppLaunch SDK
 
 This method will intialize the AppLaunchConfig with the help of Builder Class. The builder class parameters are optional,
 
 - parameter cacheExpiration(Optional): Cache expiration timeout value
 - parameter deviceID(Optional): used to ovveride device ID. AppLaunch SDK generates deviceID by default if this is not set.
 - parameter eventFlushInterval(Optional): Event Flish interval value
 - parameter fetchPolicy(Optional): Actions fetch policy
 
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
    
    public class Builder {
        // default values
        internal var policy: RefreshPolicy = .REFRESH_ON_EVERY_START
        internal var deviceID: String = AppLaunchUtils.getDeviceID()
        internal var cacheExpiration: Float = 60
        internal var eventFlushInterval: Float = 60
        
        public init() {
            
        }
        
        public func fetchPolicy(_ policy: RefreshPolicy) -> Builder {
            self.policy = policy
            return self
        }
        
        public func cacheExpiration(_ cacheExpiration: Float) -> Builder {
            self.cacheExpiration = cacheExpiration
            return self
        }
        
        public func eventFlushInterval(_ eventFlushInterval: Float) -> Builder {
            self.eventFlushInterval = eventFlushInterval
            return self
        }
        
        public func deviceID(_ deviceID: String) -> Builder {
            self.deviceID = deviceID
            return self
        }
        
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






