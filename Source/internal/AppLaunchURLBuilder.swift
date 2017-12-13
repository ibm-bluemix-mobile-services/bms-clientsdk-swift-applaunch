//
//  AppLaunchURLBuilder.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

internal class AppLaunchURLBuilder: NSObject {
    private var baseURL:String
    private var applicationID:String
    
    init(_ region:String,_ appID:String) {
        baseURL = "\(MOBILESERVICES)\(region)/\(APPLAUNCH_CONTEXT)"
        applicationID = appID
    }
    
    func getAppRegistrationURL() -> String {
        return self.baseURL+"/apps/\(applicationID)/users"
    }
    
    func getUserURL(_ userId:String) -> String {
        return getAppRegistrationURL() + "/\(userId)"
    }
    
    func getActionURL(_ userId:String) -> String {
        return getAppRegistrationURL() + "/\(userId)/actions"
    }
    
    func getMetricsURL(_ userId:String) -> String {
        return getAppRegistrationURL() + "/\(userId)/events/metrics"
    }
}
