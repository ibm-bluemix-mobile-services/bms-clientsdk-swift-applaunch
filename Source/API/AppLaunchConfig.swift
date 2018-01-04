//
//  AppLaunchConfig.swift
//  AppLaunch
//
//  Created by Vittal Pai on 1/2/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON

public class AppLaunchConfig {
    
    private var policy: RefreshPolicy
    private var cacheExpiration: Int
    private var eventFlushInterval: Int
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
        
        internal var policy: RefreshPolicy = .REFRESH_ON_EVERY_START
        internal var deviceID: String = AppLaunchUtils.getDeviceID()
        internal var cacheExpiration: Int = 0
        internal var eventFlushInterval: Int = 0
        
        public func fetchPolicy(_ policy: RefreshPolicy) -> Builder {
            self.policy = policy
            return self
        }
        
        public func cacheExpiration(_ cacheExpiration: Int) -> Builder {
            self.cacheExpiration = cacheExpiration
            return self
        }
        
        public func eventFlushInterval(_ eventFlushInterval: Int) -> Builder {
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
    
    internal func getCacheExpiration() -> Int {
        return cacheExpiration
    }
    
    internal func getEventFlushInterval() -> Int {
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






