//
//  AppLaunchURLBuilder.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

internal class AppLaunchURLBuilder {
    private var baseURL:String
    private var applicationID:String
    private let FORWARDSLASH = "/"
    private let APPS = "/apps"
    private let USERS = "/users"
    private let ACTIONS = "/actions"
    private let EVENTS = "/events"
    private let METRICS = "/metrics"
    private let MOBILESERVICES:String = "http://mobileservices"
    private let APPLAUNCH_CONTEXT:String = "/applaunch/v1"
    
    init(_ region:String,_ appID:String) {
        baseURL = MOBILESERVICES + FORWARDSLASH + region + APPLAUNCH_CONTEXT
        applicationID = appID
    }
    
    func getAppRegistrationURL() -> String {
        return self.baseURL + APPS + FORWARDSLASH + applicationID + USERS
    }
    
    func getUserURL(_ userId:String) -> String {
        return getAppRegistrationURL() + FORWARDSLASH + USER_ID
    }
    
    func getActionURL(_ userId:String) -> String {
        return getAppRegistrationURL() + FORWARDSLASH + userId + ACTIONS
    }
    
    func getMetricsURL(_ userId:String) -> String {
        return getAppRegistrationURL() + FORWARDSLASH + userId + EVENTS + METRICS
    }
    
    func getInAppMessagingURL(_ userId:String) -> String {
        return getAppRegistrationURL() + FORWARDSLASH + userId + "/captivateengine/inappmsg"
    }
}
