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
    
    class func saveUserContext(userId:String, applicationId:String, deviceId:String, region:String, attributes: JSON){
        let defaults = AppLaunchCacheManager.sharedInstance
        print("Saving user context :: userId:\(userId), applicationId:\(applicationId), deviceId:\(deviceId), region:\(region)")
        defaults.addString(userId, USER_ID)
        defaults.addString(deviceId, DEVICE_ID)
        defaults.addString(applicationId, APP_ID)
        defaults.addString(region, REGION)
        if attributes != JSON.null {
            defaults.addString(attributes.rawString()!, ATTRIBUTES)
        }
    }
    
    class func userNeedsToBeRegistered(_ userId: String,_ applicationId: String,_ deviceId: String,_ region: String) -> Bool {
        let defaults = AppLaunchCacheManager.sharedInstance
        
        if (!defaults.readString(USER_ID).isEmpty && !defaults.readString(DEVICE_ID).isEmpty && !defaults.readString(APP_ID).isEmpty && !defaults.readString(REGION).isEmpty) {
            return false
        }
        return true
    }
    
    class func isUpdateRegistrationRequired(_ userId: String,_ applicationId: String,_ deviceId: String,_ region: String,_ attributes: JSON) -> Bool {
        let defaults = AppLaunchCacheManager.sharedInstance
        if userNeedsToBeRegistered(userId, applicationId, deviceId, region) {
            return false
        }
        if (defaults.readString(USER_ID) == userId && defaults.readJSON(ATTRIBUTES) == attributes && defaults.readString(DEVICE_ID) == deviceId && defaults.readString(APP_ID) == applicationId && defaults.readString(REGION) == region) {
            // Stored app data and device data is not changed
            return false
        }
        return true
    }
    
    class func getCurrentDate() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return Int(formatter.string(from: Date()))!
    }

}
