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
//  AppLaunchFailResponse.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/18/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: - Swift 3 & Swift 4

/**
 This is the Failure Response class in the `AppLaunch`.
 It is used to handle the failure responses from the AppLaunch REST API calls.
 */
public class AppLaunchFailResponse {
    private var errorCode: ErrorCode
    private var errorMessage: String
    
    /**
     This method will intialize the AppLaunchFailResponse with Error Code and Error Message
     
     - parameter errorCode: This is Error Code value
     - parameter errorMessage: This is Error Message value
     */
    internal init(_ errorCode: ErrorCode,_ errorMessage: String) {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
    
    // MARK: Methods
    
    /**
     
     This Methode returns the error code for the `AppLaunch` calling API
     
     - returns: errorCode: This returns the error code value from the AppLaunch Service
     */
    public func getErrorCode() -> ErrorCode {
        return errorCode
    }
    
    /**
     
     This Methode returns the error message for the `AppLaunch` calling API
     
     - returns: errorMessage: This returns the error message value from the AppLaunch Service
     */
    public func getErrorMessage() -> String {
        return errorMessage
    }
    
}
