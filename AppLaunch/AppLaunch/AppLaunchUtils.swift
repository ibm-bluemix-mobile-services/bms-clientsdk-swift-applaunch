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

}
