//
//  AppLaunchResponse.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/18/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: - Swift 3 & Swift 4

/**
 This is the Success Response class in the `AppLaunch`.
 It is used to handle the success responses from the AppLaunch REST API calls.
 */
public class AppLaunchResponse {
    private var status:Int
    private var responseText:String
    private var responseJSON:JSON
    
    
    /**
     This method will intialize the AppLaunchResponse with status, responseText and responseJSON
     
     - parameter status: This is status value
     - parameter responseText: clientSecret appLaunch client secret value
     - parameter responseJSON: bluemixRegionSuffix specifies the location where the app is hosted
     */
    internal init(_ status: Int,_ responseText:String? = nil, _ responseJSON: JSON? = JSON.null) {
        self.status = status
        self.responseText = responseText!
        self.responseJSON = responseJSON!
    }
    
    // MARK: Methods
    
    /**
     
     This Methode returns the status code for the AppLaunch calling API
     
     - returns: Int: This returns the status value from the AppLaunch Service
     */
    public func getStatus() -> Int {
        return status
    }
    
    /**
     
     This Methode returns the response text for the AppLaunch calling API
     
     - returns: responseText: This returns the responseText from the AppLaunch Service
     */
    public func getResponseText() -> String {
        return responseText
    }
    
    /**
     
     This Methode returns the response JSON for the AppLaunch calling API
     
     - returns: responseJSON: This returns the responseJSON from the AppLaunch Service
     */
    public func getResponseJSON() -> JSON {
        return responseJSON
    }
    
}
