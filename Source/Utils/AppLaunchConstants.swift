//
//  AppLaunchConstants.swift
//  AppLaunch
//
//  Created by Chethan Kumar on 9/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Enum and TypeAlias which are available in AppLaunch SDK
 */

/**
 `ICRegion` is an enumerator which can be used to specify IBM Cloud region where AppLaunch Service is hosted.
 */
public enum ICRegion : String {
    
    case US_SOUTH = ".us-south.containers.mybluemix.net"
    
    case UNITED_KINGDOM = ".eu-gb.containers.mybluemix.net"
    
    case SYDNEY = ".sydney.containers.mybluemix.net"
    
    case US_SOUTH_STAGING = "-staging.us-south.containers.mybluemix.net"
    
    case UNITED_KINGDOM_STAGING = "-staging.eu-gb.containers.mybluemix.net"
    
    case SYDNEY_STAGING = "-staging.sydney.containers.mybluemix.net"
    
    case US_SOUTH_DEV = "-dev.us-south.containers.mybluemix.net"
    
    case UNITED_KINGDOM_DEV = "-dev.eu-gb.containers.mybluemix.net"
    
    case SYDNEY_DEV = "-dev.sydney.containers.mybluemix.net"
    
}

/**
 `RefreshPolicy` is an enumerator which can be used to specify the session refresh policy
 */
public enum RefreshPolicy : Int {
    
    case REFRESH_ON_EVERY_START = 0
    
    case REFRESH_ON_EXPIRY = 1
    
    case BACKGROUND_REFRESH = 2
    
}

/**
 `ErrorCode` is an enumerator which contains error information.
 */
public enum ErrorCode : Int {
    
    case REGISTRATION_FAILURE = 0
    
    case FETCH_ACTIONS_FAILURE = 1
    
    case DEFAULT_FEATURE_LOAD_FAILURE = 3
    
    case UNREGISTRATION_FAILURE = 4
    
}

/**
 `AppLaunchCompletionHandler` is a callback for AppLaunch REST APIs.
 */
public typealias AppLaunchCompletionHandler = (_ Response:AppLaunchResponse?, _ Error:AppLaunchFailResponse? ) -> Void


//
// ─── INTERNAL CONSTANTS ───────────────────────────────────────────────────────────
//

internal let APPLICATION_ID:String = "applicationId"

internal let IOS:String = "iOS"

internal let DEVICE_ID:String = "deviceId"

internal let PLATFORM:String = "platform"

internal let APP_ID:String = "appId"

internal let APP_VERSION:String = "appVersion"

internal let APP_NAME:String = "appName"

internal let USER_ID:String = "userId"

internal let ATTRIBUTES:String = "attributes"

internal let APPLICATION_JSON = "application/json; charset = UTF-8"

internal let CONTENT_TYPE = "Content-Type"

internal let METRIC_CODES = "metricCodes"

internal let METRICS = "metrics"

internal let ACTION = "action"

internal let CLIENT_SECRET = "clientSecret"

internal let REGION = "region"

internal let NAME:String = "name"

internal let CODE:String = "code"

internal let FEATURES:String = "features"

internal let TRIGGERS:String = "triggers"

internal let PROPERTIES:String = "properties"

internal let VALUE:String = "value"

internal let INAPP:String = "inApp"

internal let IMAGE_URL:String = "imageUrl"

internal let LAYOUT:String = "layout"

internal let CACHE_EXPIRATION:String = "CACHE_EXPIRATION"


