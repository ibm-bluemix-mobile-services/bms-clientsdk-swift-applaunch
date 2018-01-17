//
//  AppLaunchUser.swift
//  AppLaunch
//
//  Created by Vittal Pai on 1/2/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON


/**
 `AppLaunchUser` contains user information which is used by `AppLaunch` APIs
 
 This method will intialize the AppLaunchUser with the help of Builder Class.
 */
public class AppLaunchUser {
    
    private var userID: String
    private var attributes: JSON
    
    init(_ builder: Builder) {
        self.userID = builder.userID
        self.attributes = builder.attributes
    }
    
    /**
     Builder class of `AppLaunchUser`
     */
    public class Builder {
        
        internal var userID: String
        internal var attributes: JSON = JSON()
        
        /**
         Initializer for builder class of `AppLaunchUser`
         
         - parameter userId: userID value.
         */
        public init(userId: String) {
            self.userID = userId
        }
        
        /**
          This is an optional method which can be used to set any custom user attributes.
         */
        public func custom(key: String, value: String) -> Builder {
            self.attributes[key].stringValue = value
            return self
        }
        
        /**
         This method builds AppLaunch User object.
         
         - returns: `AppLaunchUser` object
         */
        public func build() -> AppLaunchUser {
            return AppLaunchUser(self)
        }
        
    }
    
    internal func getUserId() -> String {
        return userID
    }
    
    internal func getAttributes() -> JSON {
        if (attributes.isEmpty) {
            return JSON.null
        }
        return attributes
    }
    
}





