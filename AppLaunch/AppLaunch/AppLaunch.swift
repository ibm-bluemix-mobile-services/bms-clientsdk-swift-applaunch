//
//  AppLaunch.swift
//  AppLaunch
//
//  Created by Chethan Kumar on 9/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import BMSCore
import SwiftyJSON

// ─────────────────────────────────────────────────────────────────────────

private var APP_LAUNCH_SERVER:String = String()

public class AppLaunch:NSObject{
    
public private(set) var clientSecret: String?

public private(set) var applicationId: String?

public private(set) var region: String?

private var deviceId = String()

public static let sharedInstance = AppLaunch()

private var bmsClient = BMSClient.sharedInstance

private var isInitialized = false

private var isUserRegistered = false

private var userId:String = String()
    
private var features:JSON = nil
    
//
// ─── INITIALIZE ────────────────────────────────────────────────────────────
//
    
public func initializeWithAppGUID (applicationId: String, clientSecret: String, region: String) {
    
    if AppLaunchUtils.validateString(object: clientSecret) &&  AppLaunchUtils.validateString(object: applicationId) && AppLaunchUtils.validateString(object: region){
        
        self.clientSecret = clientSecret
        self.applicationId = applicationId
        self.region = region
        if(UserDefaults.standard.value(forKey: USER_ID) != nil){
            self.userId = UserDefaults.standard.value(forKey: USER_ID) as! String
        }else{
            self.userId = ""
        }
        
        APP_LAUNCH_SERVER = "\(MOBILESERVICES)\(region)/\(APPLAUNCH_CONTEXT)"
        
        isInitialized = true;
        
        let authManager  = BMSClient.sharedInstance.authorizationManager
        self.deviceId = authManager.deviceIdentity.ID!
        AppLaunchUtils.saveValueToNSUserDefaults(value: self.deviceId, key: DEVICE_ID)
    }
    else{
        print(MSG__CLIENT_OR_APPID_NOT_VALID)
    }
}
    
//
// ─── REGISTER USER ──────────────────────────────────────────────────────────
//

public func registerWith(userId:String,completionHandler:@escaping(_ response:String, _ statusCode:Int, _ error:String) -> Void){
    if(isInitialized) {
        
        if(!AppLaunchUtils.userNeedsToBeRegistered(userId: userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)){
            self.userId = userId
            completionHandler(MSG__USER_ALREADY_REGISTERED,201,"")
        } else {
        
            var deviceData:JSON = JSON()
            deviceData[DEVICE_ID].string = self.deviceId
            deviceData[MODEL].string = UIDevice.current.modelName
            deviceData[BRAND].string = APPLE
            deviceData[OS_VERSION].string = UIDevice.current.systemVersion
            deviceData[PLATFORM].string = IOS
            deviceData[APP_ID].string = Bundle.main.bundleIdentifier!
            deviceData[APP_VERSION].string = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            deviceData[APP_NAME].string = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
            deviceData[USER_ID].string = userId
            
            let userRegUrl = APP_LAUNCH_SERVER+"/apps/\(self.applicationId!)/users"
            
            var  headers = [String:String]()
            headers.updateValue(APPLICATION_JSON, forKey: CONTENT_TYPE)
            headers.updateValue(self.clientSecret!, forKey: CLIENT_SECRET)
            
            let createUserRequest = Request(url: userRegUrl, method: HttpMethod.POST,headers: headers, queryParameters: nil, timeout: 60)
            
            createUserRequest.send(requestBody: deviceData.description.data(using: .utf8),completionHandler:{(response,error) in
                
                if(response != nil){
                    let responseText = response?.responseText ?? ""
                    let status = response?.statusCode ?? 0
                    if(status == 200 || status == 201){
                        self.isUserRegistered = true
                        self.userId = userId
                        AppLaunchUtils.saveUserContext(userId: userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)
                        AppLaunchUtils.saveValueToNSUserDefaults(value: TRUE, key: IS_USER_REGISTERED)
                        completionHandler(responseText,status,"")
                    }else{
                        completionHandler("", status, responseText)
                        self.isUserRegistered = false
                    }
                }else if let responseError = error{
                    completionHandler("", 500, responseError.localizedDescription)
                }
            })
        }
    }
}
    
//
// ─── UPDATE USER ───────────────────────────────────────────────────────────
//

public func updateUserWith(userId:String,attribute:String,value:Any, completionHandler:@escaping(_ response:String, _ statusCode:Int, _ error:String) -> Void){
    
    var deviceData:JSON = JSON()
    deviceData[DEVICE_ID].string = self.deviceId
    deviceData[USER_ID].string = self.userId
    switch type(of: value) {
    case is String.Type:
        deviceData[attribute].string = value as! String
        
    case is Numeric.Type:
        deviceData[attribute].number = value as! NSNumber
        
    case is Bool.Type:
        deviceData[attribute].boolValue = value as! Bool
        
    default:
        break
    }
    
    let userRegUrl = APP_LAUNCH_SERVER+"/apps/\(self.applicationId!)/users/\(userId)"
    
    var  headers = [String:String]()
    headers.updateValue(APPLICATION_JSON, forKey: CONTENT_TYPE)
    headers.updateValue(self.clientSecret!, forKey: CLIENT_SECRET)
    
    let createUserRequest = Request(url: userRegUrl, method: HttpMethod.PUT,headers: headers, queryParameters: nil, timeout: 60)
    
    createUserRequest.send(requestBody: deviceData.description.data(using: .utf8),completionHandler:{(response,error) in
        
        if(response != nil){
            let responseText = response?.responseText ?? ""
            let status = response?.statusCode ?? 0
            if(status == 200 || status == 201){
                self.isUserRegistered = true
                AppLaunchUtils.saveUserContext(userId: userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)
                AppLaunchUtils.saveValueToNSUserDefaults(value: TRUE, key: IS_USER_REGISTERED)
                self.userId = userId
                completionHandler(responseText,status,"")
            }else{
                completionHandler("", status, responseText)
                self.isUserRegistered = false
            }
        }else if let responseError = error{
            completionHandler("", 500, responseError.localizedDescription)
        }
    })
}
    
//
// ─── ACTIONS ───────────────────────────────────────────────────────────────
//
    
public func actions(completionHandler:@escaping(_ features:JSON?, _ statusCode:Int?, _ error:String) -> Void){
    
    if(isInitialized && !AppLaunchUtils.userNeedsToBeRegistered(userId: self.userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)){
        
        let resourceURL:String = APP_LAUNCH_SERVER+"/apps/\(self.applicationId!)/users/\(self.userId)/actions"
        
        var headers = [CONTENT_TYPE : APPLICATION_JSON]
        headers.updateValue(self.clientSecret!, forKey: CLIENT_SECRET)
        
        var queryParam = [String:String]()
        queryParam.updateValue(self.deviceId, forKey: DEVICE_ID)
        
        let getActionsRequest = Request(url: resourceURL, method: HttpMethod.GET,headers: headers, queryParameters: queryParam, timeout: 60)
        
        
        getActionsRequest.send(completionHandler: { (response, error) in
            if response != nil {
                let status = response?.statusCode ?? 0
                let responseText = response?.responseText ?? ""
                
                if(status == 200 || status == 201){
                    if let data = responseText.data(using: String.Encoding.utf8) {
                        let respJson = JSON(data: data)
                        
                        print("response data from server \(responseText)")
                        self.features = respJson["features"];
                        completionHandler(respJson["features"],200,"")
                    }
                }else{
                    print("[404] Actions Not found")
                    completionHandler(nil,status,responseText)
                }
                
            }else {
                completionHandler([], 500 , MSG__ERR_GET_ACTIONS)
            }
        })
        
    }else{
        completionHandler([], 500 , MSG__ERR_NOT_REG_NOT_INIT)
        
    }
}
    
//
// ─── FEATURES ──────────────────────────────────────────────────────────────
//

public func hasFeatureWith(code:String) -> Bool{
    var hasFeature = false
    for(key,feature) in self.features{
        if let featureCode = feature["code"].string{
            if featureCode == code{
                hasFeature = true
            }
        }
    }
    return hasFeature
}


public func getValueFor(featureWithCode:String,variableWithCode:String) -> String{
    for(key,feature) in self.features{
        if let featureCode = feature["code"].string{
            if featureCode == featureWithCode{
                for(k,variable) in feature["variables"]{
                    if let varibleCode = variable["code"].string{
                        if varibleCode == variableWithCode{
                            return variable["value"].stringValue
                        }
                    }
                }
            }
        }
    }
    return ""
}
    
public func getValueFor(featureWithCode:String,propertiesWithCode:String) -> String{
    for(key,feature) in self.features{
        if let featureCode = feature["code"].string{
            if featureCode == featureWithCode{
                for(k,variable) in feature["variables"]{
                    if let varibleCode = variable["code"].string{
                        if varibleCode == propertiesWithCode{
                            return variable["value"].stringValue
                        }
                    }
                }
            }
        }
    }
    return ""
}

//
// ─── METRICS ──────────────────────────────────────────────────────────────
//

public func sendMetricsWith(code:String) -> Void{
    if(isInitialized && !AppLaunchUtils.userNeedsToBeRegistered(userId: self.userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)){
        
        var metricsData:JSON = JSON()
        metricsData[DEVICE_ID].string = self.deviceId
        metricsData[USER_ID].string = self.userId
        metricsData[METRIC_CODES].arrayObject = [code]
        
        print("metrics payload \(metricsData.description)")
        
        let resourceURL:String = APP_LAUNCH_SERVER+"/apps/\(self.applicationId!)/users/\(self.userId)/events/metrics"
        
        //TODO add client secret in headers
        var headers = [CONTENT_TYPE : APPLICATION_JSON]
        headers.updateValue(self.clientSecret!, forKey: CLIENT_SECRET)
        
        var queryParam = [String:String]()
        queryParam.updateValue(self.deviceId, forKey: DEVICE_ID)
        
        let metricsRequest = Request(url: resourceURL, method: HttpMethod.POST,headers: headers, queryParameters: queryParam, timeout: 60)
        
        metricsRequest.send(requestBody: metricsData.description.data(using: .utf8),completionHandler:{(response,error) in
            
            let status = response?.statusCode ?? 0
            if(status == 200){
                print("sent metrics for code : \(code)")
            }else if let responseError = error{
                print("Error in sending metrics for code : \(code) with error :\(responseError.localizedDescription)")
            }
            
        })
    }else{
        print(MSG__ERR_METRICS_NOT_INIT)
    }
    
}
    

}
