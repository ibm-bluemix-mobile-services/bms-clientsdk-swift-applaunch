//
//  AppLaunchUtils.swift
//  AppLaunch
//
//  Created by Chethan Kumar on 9/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON

internal class AppLaunchUtils:NSObject{
    
    class func saveValueToNSUserDefaults (value:String, key:String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        print("Saving value to NSUserDefaults with Key: \(key) and Value: \(value)")
    }
    
    class func getValueToNSUserDefaults (key:String) -> String {
        var value = ""
        if(UserDefaults.standard.value(forKey: key) != nil){
            value = UserDefaults.standard.value(forKey: key) as! String
        }
        print("Getting value for NSUserDefaults Key: \(key) and Value: \(value)")
        return value
    }
    
    class func validateString(object:String) -> Bool{
        if (object.isEmpty || object == "") {
            return false;
        }
        return true
    }
    
    class func getRegistrationData(_ deviceID:String,_ userID:String,_ attributes:JSON) -> JSON {
        var registrationData:JSON = JSON()
        registrationData[DEVICE_ID].string = deviceID
        registrationData[PLATFORM].string = IOS
        registrationData[USER_ID].string = userID
        if (attributes != JSON.null) {
            registrationData[ATTRIBUTES] = attributes
        }
        return registrationData
    }
    
    class func saveUserContext(userId:String, applicationId:String, deviceId:String, region:String){
        let defaults = AppLaunchCacheManager.sharedInstance
        print("Saving user context :: userId:\(userId), applicationId:\(applicationId), deviceId:\(deviceId), region:\(region)")
        defaults.addString(userId, USER_ID)
        defaults.addString(deviceId, DEVICE_ID)
        defaults.addString(applicationId, APP_ID)
        defaults.addString(region, REGION)
    }
    
    class func userNeedsToBeRegistered(userId:String, applicationId:String, deviceId:String, region:String)->Bool{
        let defaults = AppLaunchCacheManager.sharedInstance
        
        if (!defaults.readString(USER_ID).isEmpty && !defaults.readString(DEVICE_ID).isEmpty && !defaults.readString(APP_ID).isEmpty && !defaults.readString(REGION).isEmpty) {
            // Check if existing data is changed with stored data
            if (defaults.readString(USER_ID) == userId && defaults.readString(DEVICE_ID) == deviceId && defaults.readString(APP_ID) == applicationId && defaults.readString(REGION) == region) {
                // Stored app data and device data is not changed
                return false
            }
        }
        return true
    }
    
    class func getCurrentDate() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return Int(formatter.string(from: Date()))!
    }
    
}
