/*
 *     Copyright 2018 IBM Corp.
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 */

//
//  AppLaunchUtils.swift
//  AppLaunch
//
//  Created by Chethan Kumar on 9/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import BMSCore
import SwiftyJSON

internal class AppLaunchUtils:NSObject{
    
    class func validateString(object:String) -> Bool{
        if (object.isEmpty || object == "") {
            return false;
        }
        return true
    }
    
    class func getDeviceID() -> String {
        return BMSClient.sharedInstance.authorizationManager.deviceIdentity.ID!
    }
    
    class func getRegistrationData(_ user: AppLaunchUser,_ config: AppLaunchConfig) -> JSON {
        var registrationData:JSON = JSON()
        registrationData[DEVICE_ID].string = config.getDeviceID()
        registrationData[PLATFORM].string = MOBILE
        registrationData[OS].string = IOS
        registrationData[USER_ID].string = user.getUserId()
        if (user.getAttributes() != JSON.null) {
            registrationData[ATTRIBUTES] = user.getAttributes()
        }
        return registrationData
    }
    
    class func getUpdateRegistrationData(_ user: AppLaunchUser,_ config: AppLaunchConfig) -> JSON {
        var registrationData:JSON = getRegistrationData(user, config)
        registrationData.dictionaryObject?.removeValue(forKey: DEVICE_ID)
        return registrationData
    }
    
    class func saveUserContext(_ user: AppLaunchUser,_ config: AppLaunchConfig){
        let defaults = AppLaunchCacheManager.sharedInstance
        defaults.addString(user.getUserId(), USER_ID)
        defaults.addString(config.getDeviceID(), DEVICE_ID)
        defaults.addString(config.getAppID(), APP_ID)
        defaults.addString(config.getICRegion(), REGION)
        if user.getAttributes() != JSON.null {
            defaults.addString(user.getAttributes().rawString()!, ATTRIBUTES)
        }
    }
    
    class func userNeedsToBeRegistered() -> Bool {
        let defaults = AppLaunchCacheManager.sharedInstance
        
        if (!defaults.readString(USER_ID).isEmpty && !defaults.readString(DEVICE_ID).isEmpty && !defaults.readString(APP_ID).isEmpty && !defaults.readString(REGION).isEmpty) {
            return false
        }
        return true
    }
    
    class func isUserNeedsToBeReRegistered(_ user: AppLaunchUser,_ config: AppLaunchConfig) -> Bool {
        let defaults = AppLaunchCacheManager.sharedInstance
        if (defaults.readString(USER_ID) == user.getUserId() && defaults.readJSON(ATTRIBUTES) == user.getAttributes() && defaults.readString(DEVICE_ID) == config.getDeviceID() && defaults.readString(APP_ID) == config.getAppID() && defaults.readString(REGION) == config.getICRegion()) {
            // Stored app data and device data is not changed
            return false
        }
        return true
    }
    
    
    
    class func isUpdateRegistrationRequired(_ user: AppLaunchUser,_ config: AppLaunchConfig) -> Bool {
        let defaults = AppLaunchCacheManager.sharedInstance
        if defaults.readString(DEVICE_ID) != config.getDeviceID() {
            return false
        }
        if (defaults.readString(USER_ID) == user.getUserId() && defaults.readJSON(ATTRIBUTES) == user.getAttributes()) {
            // user data is not changed
            return false
        }
        return true
    }
    
    class func getCurrentDate() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return Int(formatter.string(from: Date()))!
    }
    
    class func getCurrentDateAndTime() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhhmmss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return Int(formatter.string(from: Date()))!
    }
    
}
