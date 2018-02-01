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
