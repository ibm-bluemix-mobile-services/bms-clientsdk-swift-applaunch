//
//  AppLaunchUtils.swift
//  AppLaunch
//
//  Created by Chethan Kumar on 9/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

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
    
    class func saveUserContext(userId:String, applicationId:String, deviceId:String, region:String){
        print("Saving user context :: userId:\(userId), applicationId:\(applicationId), deviceId:\(deviceId), region:\(region)")
        UserDefaults.standard.set(userId, forKey: USER_ID)
        UserDefaults.standard.set(deviceId, forKey: DEVICE_ID)
        UserDefaults.standard.set(applicationId, forKey: APP_ID)
        UserDefaults.standard.set(region, forKey: REGION)
        UserDefaults.standard.synchronize()
    }
    
    class func userNeedsToBeRegistered(userId:String, applicationId:String, deviceId:String, region:String)->Bool{
        var needsToBeRegistered = true
        var existingUserID = ""
        var existingApplicationId = ""
        var existingDeviceId = ""
        var existingRegion = ""
        
        if(UserDefaults.standard.value(forKey: USER_ID) != nil){
            existingUserID = UserDefaults.standard.value(forKey: USER_ID) as! String
            print("existing user ID : \(existingUserID)")
            if(existingUserID == userId){
                needsToBeRegistered = false
            } else {
                return true
            }
        }
        
        if(UserDefaults.standard.value(forKey: DEVICE_ID) != nil){
            existingDeviceId = UserDefaults.standard.value(forKey: DEVICE_ID) as! String
            print("existing device ID : \(existingDeviceId)")
            if(existingDeviceId == deviceId){
                needsToBeRegistered = false
            } else {
                return true
            }
        }
        
        if(UserDefaults.standard.value(forKey: APP_ID) != nil){
            existingApplicationId = UserDefaults.standard.value(forKey: APP_ID) as! String
            print("existing app ID : \(existingApplicationId)")
            if(existingApplicationId == applicationId){
                needsToBeRegistered = false
            } else {
                return true
            }
        }
        
        if(UserDefaults.standard.value(forKey: REGION) != nil){
            existingRegion = UserDefaults.standard.value(forKey: REGION) as! String
            print("existing region ID : \(existingRegion)")
            if(existingRegion == region){
                needsToBeRegistered = false
            } else {
                return true
            }
        }
        
        print("needs to be registered \(needsToBeRegistered)")
        return needsToBeRegistered
    }

}
