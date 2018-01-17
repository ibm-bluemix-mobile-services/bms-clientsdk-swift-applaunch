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
    private var responseJSON:JSON
    
    
    /**
     This method will intialize the `AppLaunchResponse` with responseJSON
     
     - parameter responseJSON: Engagements JSON
     */
    internal init(_ responseJSON: JSON) {
        self.responseJSON = responseJSON
    }
    
    // MARK: Methods
    
    /**
     
     This Methode returns the response JSON for the `AppLaunch` calling API
     
     - returns: responseJSON: This returns the Engagements JSON from the AppLaunch Service
     */
    public func getResponseJSON() -> JSON {
        return responseJSON
    }
    
}
