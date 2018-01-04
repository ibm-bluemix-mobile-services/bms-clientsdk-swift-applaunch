//
//  AppLaunchUser.swift
//  AppLaunch
//
//  Created by Vittal Pai on 1/2/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON

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
        
        init(userId: String) {
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





