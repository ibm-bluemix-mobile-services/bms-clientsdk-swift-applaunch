//
//  AppLaunchEnumerators.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 ICRegion is an enumerator which can be used to specify IBM Cloud region where AppLaunch Service is hosted.
 
 ````
 case US_SOUTH
 case UNITED_KINGDOM
 case SYDNEY
 case US_SOUTH_STAGING
 case UNITED_KINGDOM_STAGING
 case US_SOUTH_DEV
 ````
 */
public enum ICRegion : String {
    
    /// US South IBM Cloud Region.
    case US_SOUTH = ".ng.bluemix.net"
    
    /// United Kingdom IBM Cloud Region.
    case UNITED_KINGDOM = ".eu-gb.bluemix.net"
    
    /// Sydney IBM Cloud Region.
    case SYDNEY = ".au-syd.bluemix.net"
    
    /// US South Staging IBM Cloud Region.
    case US_SOUTH_STAGING = ".stage1.ng.bluemix.net"
    
    /// United Kingdom Staging IBM Cloud Region.
    case UNITED_KINGDOM_STAGING = ".stage1.eu-gb.bluemix.net"
    
    /// US South Dev IBM Cloud Region.
    case US_SOUTH_DEV = "dev.ng.bluemix.net"
    
}

/**
 `RefreshPolicy` is an enumerator which can be used to specify on how frequently the engagements should be fetched from the server.
 
 ````
 case REFRESH_ON_EVERY_START
 case REFRESH_ON_EXPIRY
 case BACKGROUND_REFRESH
 ````
 */
public enum RefreshPolicy : Int {
    
    /// Loads engagements from server on every start of the application.
    case REFRESH_ON_EVERY_START = 0
    
    /// Loads engagements from server only if previous engagement is expired.
    case REFRESH_ON_EXPIRY = 1
    
    /// Loads engagements from server whenever previous engagement is expired.
    case BACKGROUND_REFRESH = 2
    
}

/**
 `ErrorCode` is an enumerator which contains error information.
 
 ````
 case INITIALIZATION_FAILURE
 case REGISTRATION_FAILURE
 case FETCH_ACTIONS_FAILURE
 case DEFAULT_FEATURE_LOAD_FAILURE
 case UNREGISTRATION_FAILURE
 ````
 */
public enum ErrorCode : Int {
    
    /// Applaunch Service is failed to initialize.
    case INITIALIZATION_FAILURE = 0
    
    /// Failed to register with Applaunch Service.
    case REGISTRATION_FAILURE = 1
    
    /// Failed to retreive engagements from Applaunch Service.
    case FETCH_ACTIONS_FAILURE = 2
    
    /// Failed to load default features from Application.
    case DEFAULT_FEATURE_LOAD_FAILURE = 3
    
    /// Failed to unregister with Applaunch Service.
    case UNREGISTRATION_FAILURE = 4
    
}


/**
 `AppLaunchError` is an enumerator which contains error codes.
 
 ````
 case applaunchNotIntialized
 ````
 */
public enum AppLaunchError: Error {
    
    /// Applaunch Service is not initialized. Invoke initialize API Function.
    case applaunchNotIntialized
}

/**
 `AppLaunchCompletionHandler` is a callback for AppLaunch REST APIs.
 */
public typealias AppLaunchCompletionHandler = (_ Response:AppLaunchResponse?, _ Error:AppLaunchFailResponse? ) -> Void
