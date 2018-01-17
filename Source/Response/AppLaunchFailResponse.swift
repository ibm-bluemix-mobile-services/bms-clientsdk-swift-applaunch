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
