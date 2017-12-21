//
//  AppLaunchConstants.swift
//  AppLaunch
//
//  Created by Chethan Kumar on 9/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

//
// ─── INTERNAL CONSTANTS ───────────────────────────────────────────────────────────
//

internal let APPLICATION_ID:String = "applicationId"

internal let IOS:String = "iOS"

internal let DEVICE_ID:String = "deviceId"

internal let MODEL:String = "model"

internal let BRAND:String = "brand"

internal let OS_VERSION:String = "OSVersion"

internal let PLATFORM:String = "platform"

internal let APP_ID:String = "appId"

internal let APP_VERSION:String = "appVersion"

internal let APP_NAME:String = "appName"

internal let USER_ID:String = "userId"

internal let APPLE:String = "Apple"

internal let BUTTONS:String = "buttons"

internal let BUTTON_NAME:String = "buttonName"

internal let BUTTON_TYPE:String = "buttonType"

internal let BUTTON_VALUE:String = "buttonValue"

internal let INVOKE_FUNCTION:String = "invoke-function"

internal let NAVIGATE:String = "navigate"

internal let APPLICATION_JSON = "application/json; charset = UTF-8"

internal let CONTENT_TYPE = "Content-Type"

internal let IS_USER_REGISTERED = "IS_USER_REGISTERED"

internal let TRUE = "true"

internal let METRIC_CODES = "metricCodes"

internal let CLIENT_SECRET = "clientSecret"

internal let REGION = "region"

internal let NAME:String = "name"

internal let CODE:String = "code"

internal let FEATURES:String = "AppLaunchFeatures"

internal let TEMPLATE_TYPE:String = "templateType"

internal let VARIABLES:String = "variables"

internal let VALUE:String = "value"

internal let CONTENT:String = "content"

internal let TITLE:String = "title"

internal let SUB_TITLE:String = "subTitle"

internal let IMAGE_URL:String = "imageUrl"

/**
 Constants and TypeAlias which are available in AppLaunch SDK
 */

public let US_SOUTH:String = ".us-south.containers.mybluemix.net"

public let UNITED_KINGDOM:String = ".eu-gb.containers.mybluemix.net"

public let SYDNEY:String = ".sydney.containers.mybluemix.net"

public let US_SOUTH_STAGING:String = "-staging.us-south.containers.mybluemix.net"

public let UNITED_KINGDOM_STAGING:String = "-staging.eu-gb.containers.mybluemix.net"

public let SYDNEY_STAGING:String = "-staging.sydney.containers.mybluemix.net"

public let US_SOUTH_DEV:String = "-dev.us-south.containers.mybluemix.net"

public let UNITED_KINGDOM_DEV:String = "-dev.eu-gb.containers.mybluemix.net"

public let SYDNEY_DEV:String = "-dev.sydney.containers.mybluemix.net"

/**
 `AppLaunchCompletionHandler` is a callback for AppLaunch REST APIs.
 */
public typealias AppLaunchCompletionHandler = (_ Response:AppLaunchResponse?, _ Error:AppLaunchFailResponse? ) -> Void

