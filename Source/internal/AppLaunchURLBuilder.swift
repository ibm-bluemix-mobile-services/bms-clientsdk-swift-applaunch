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
//  AppLaunchURLBuilder.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

internal class AppLaunchURLBuilder {
    private let baseURL:String
    private let applicationID:String
    private let deviceID:String
    private let FORWARDSLASH = "/"
    private let APPS = "/apps"
    private let DEVICES = "/devices"
    private let ACTIONS = "/actions"
    private let EVENTS = "/events"
    private let METRICS = "/metrics"
    private let ACTIVATION = "/activation"
    private let SESSIONACTIVITY = "/sessionActivity"
    private let MOBILESERVICES:String = "https://applaunch"
    private let APPLAUNCH_CONTEXT:String = "/applaunch/v1"
    
    
    init(_ region: String,_ appID: String,_ deviceID: String) {
        self.baseURL = MOBILESERVICES + region + APPLAUNCH_CONTEXT
        self.applicationID = appID
        self.deviceID = deviceID
    }
    
    func getAppRegistrationURL() -> String {
        return self.baseURL + APPS + FORWARDSLASH + applicationID + DEVICES
    }
    
    func getUserURL() -> String {
        return getAppRegistrationURL() + FORWARDSLASH + deviceID
    }
    
    func getActionURL() -> String {
        return getAppRegistrationURL() + FORWARDSLASH + deviceID + ACTIONS
    }
    
    func getMetricsURL() -> String {
        return getAppRegistrationURL() + FORWARDSLASH + deviceID + EVENTS + METRICS
    }
    
    func getActivationURL() -> String {
        return getAppRegistrationURL() + FORWARDSLASH + deviceID + EVENTS + ACTIVATION
    }
    
    func getSessionURL() -> String {
        return getAppRegistrationURL() + FORWARDSLASH + deviceID + EVENTS + SESSIONACTIVITY
    }
    
}
