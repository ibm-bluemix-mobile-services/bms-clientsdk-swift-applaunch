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
 AppLaunchUser contains user information which is used by AppLaunch SDK
 
 This method will intialize the AppLaunchUser with the help of Builder Class.
 
 - parameter userId: userID value
 - parameter custom(Optional): custome user information key and value pair
 
 */
public class AppLaunchUser {
    
    private var userID: String
    private var attributes: JSON
    
    init(_ builder: Builder) {
        self.userID = builder.userID
        self.attributes = builder.attributes
    }
    
    public class Builder {
        
        internal var userID: String
        internal var attributes: JSON = JSON()
        
        public init(userId: String) {
            self.userID = userId
        }
        
        public func custom(key: String, value: String) -> Builder {
            self.attributes[key].stringValue = value
            return self
        }
        
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





