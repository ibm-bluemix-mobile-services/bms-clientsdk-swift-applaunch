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
    private let SESSIONACTIVITY = "/sessionActivity"
    private let MOBILESERVICES:String = "https://applaunch"
    private let APPLAUNCH_CONTEXT:String = "/applaunch/v1"
    
    
    init(_ region:String,_ appID:String,_ deviceID:String) {
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
    
    func getSessionURL() -> String {
        return getAppRegistrationURL() + FORWARDSLASH + deviceID + EVENTS + SESSIONACTIVITY
    }
    
}
