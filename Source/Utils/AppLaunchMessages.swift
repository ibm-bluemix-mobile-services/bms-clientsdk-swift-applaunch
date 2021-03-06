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
//  AppLaunchMessages.swift
//  AppLaunch
//
//  Created by Chethan Kumar on 9/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation


//
// ─── ERROR MESSAGES ───────────────────────────────────────────────────────────
//

internal let MSG__CLIENT_OR_APPID_NOT_VALID = "Error while initializing - Client secret or applicationID is not valid"

internal let MSG__ERR_NOT_INIT = "AppLaunch SDK is not initialized or the user is not registered. Initialize the SDK before using this API"

//
// ─── INTERNAL CONSTANTS ───────────────────────────────────────────────────────────
//

internal let APPLICATION_ID:String = "applicationId"

internal let IOS:String = "iOS"

internal let MOBILE:String = "Mobile"

internal let DEVICE_ID:String = "deviceId"

internal let PLATFORM:String = "platform"

internal let OS:String = "os"

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

internal let LABEL:String = "label"

internal let CODE:String = "code"

internal let FEATURES:String = "features"

internal let TRIGGERS:String = "triggers"

internal let PROPERTIES:String = "properties"

internal let VALUE:String = "value"

internal let INAPP:String = "inApp"

internal let IMAGE_URL:String = "imageUrl"

internal let LAYOUT:String = "layout"

internal let CACHE_EXPIRATION:String = "CACHE_EXPIRATION"

internal let SERVICE_NAME:String = "APPLAUNCH"
