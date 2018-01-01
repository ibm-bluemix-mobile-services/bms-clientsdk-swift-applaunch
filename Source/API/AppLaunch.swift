//
//  AppLaunch.swift
//  AppLaunch
//
//  Created by Chethan Kumar & Vittal Pai on 9/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import BMSCore
import SwiftyJSON

// MARK: - Swift 3 & Swift 4

/**
 A singleton that serves as an entry point to IBM Cloud AppLaunch service communication.
 */
public class AppLaunch:NSObject{
    
    // MARK: Properties
    
    /// This singleton should be used for all `AppLaunch` activity.
    public static let sharedInstance = AppLaunch()
    
    
    public typealias AppLaunchCompletionHandler1 = Int
    
    private var clientSecret: String?
    
    private var applicationId: String?
    
    private var region: String?
    
    private var deviceId = String()
    
    private var bmsClient = BMSClient.sharedInstance
    
    private var isInitialized = false
    
    private var isUserRegistered = false
    
    private var userId:String = String()
    
    private var URLBuilder:AppLaunchURLBuilder? = nil
    
    // MARK: Initializers
    
    /**
     The required initializer for the `AppLaunch` class.
     
     This method will intialize the AppLaunch with appID, clientSecret and region based registration.
     
     - parameter applicationId: app GUID value
     - parameter clientSecret: clientSecret appLaunch client secret value
     - parameter region: bluemixRegionSuffix specifies the location where the app is hosted
     */
    public func initializeWithAppGUID (applicationId: String, clientSecret: String, region: String) {
        
        if AppLaunchUtils.validateString(object: clientSecret) &&  AppLaunchUtils.validateString(object: applicationId) && AppLaunchUtils.validateString(object: region){
            let authManager  = BMSClient.sharedInstance.authorizationManager
            
            self.clientSecret = clientSecret
            self.applicationId = applicationId
            self.region = region
            self.deviceId = authManager.deviceIdentity.ID!
            AppLaunchCacheManager.sharedInstance.loadDefaultFeatures()
            displayInAppActions()
            
            if(UserDefaults.standard.value(forKey: USER_ID) != nil){
                self.userId = UserDefaults.standard.value(forKey: USER_ID) as! String
            }else{
                self.userId = ""
            }
            
            self.URLBuilder = AppLaunchURLBuilder(region, applicationId, deviceId)
            isInitialized = true;
            
            AppLaunchUtils.saveValueToNSUserDefaults(value: self.deviceId, key: DEVICE_ID)
        }
        else{
            print(MSG__CLIENT_OR_APPID_NOT_VALID)
        }
    }
    
    // MARK: Methods
    
    /**
     
     This Methode used to register the client device to the IBM Cloud AppLaunch service.
     
     - Parameter userID: This is the userId value.
     
     - returns: AppLaunchCompletionHandler: A completion-handler callback function. In the case of a successful completion, the success information is returned in the AppLaunchResponse. In the case of a unsuccessful completion, the error information is returned in the AppLaunchFailResponse
     */
    public func registerWith(userId:String,attributes: JSON? = JSON.null,completionHandler:@escaping AppLaunchCompletionHandler){
        if(isInitialized) {
            
            if(!AppLaunchUtils.userNeedsToBeRegistered(userId: userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)){
                self.userId = userId
                completionHandler(AppLaunchResponse(201, MSG__USER_ALREADY_REGISTERED), nil)
            } else {
                let registrationData:JSON = AppLaunchUtils.getRegistrationData(self.deviceId, userId, attributes!)
                let request = AppLaunchInvoker(url: URLBuilder!.getAppRegistrationURL(), method: HttpMethod.POST, timeout: 60)
                request.addHeader(APPLICATION_JSON, CONTENT_TYPE)
                request.addHeader(self.clientSecret!, CLIENT_SECRET)
                request.setJSONRequestBody(registrationData)
                request.setCompletionHandler({(response,error) in
                    if(response != nil){
                        let responseText = response?.responseText ?? ""
                        let status = response?.statusCode ?? 0
                        if(status == 200 || status == 201){
                            self.isUserRegistered = true
                            self.userId = userId
                            AppLaunchUtils.saveUserContext(userId: userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)
                            AppLaunchUtils.saveValueToNSUserDefaults(value: TRUE, key: IS_USER_REGISTERED)
                            completionHandler(AppLaunchResponse(status,responseText), nil)
                        }else{
                            completionHandler(nil, AppLaunchFailResponse(status, responseText))
                            self.isUserRegistered = false
                        }
                    }else if let responseError = error{
                        completionHandler(nil, AppLaunchFailResponse(500,responseError.localizedDescription))
                    }
                })
                request.execute()
            }
        }
    }
    
    /**
     
     This Methode used to update the user information in the IBM Cloud AppLaunch service.
     
     - Parameter userID: This is the userId value.
     - Parameter attribute: This is the attribute value.
     
     - returns: AppLaunchCompletionHandler: A completion-handler callback function. In the case of a successful completion, the success information is returned in the AppLaunchResponse. In the case of a unsuccessful completion, the error information is returned in the AppLaunchFailResponse
     */
    public func updateUserWith(userId:String,attribute:String,value:Any, completionHandler:@escaping AppLaunchCompletionHandler){
        
        var deviceData:JSON = JSON()
        deviceData[DEVICE_ID].string = self.deviceId
        deviceData[USER_ID].string = self.userId
        switch type(of: value) {
        case is String.Type:
            deviceData[attribute].string = value as? String
            
        case is Int.Type:
            deviceData[attribute].number = value as? NSNumber
            
        case is Bool.Type:
            deviceData[attribute].boolValue = value as! Bool
            
        default:
            break
        }
        
        let request = AppLaunchInvoker(url: (URLBuilder?.getUserURL())!, method: HttpMethod.PUT, timeout: 60)
        request.addHeader(APPLICATION_JSON, CONTENT_TYPE)
        request.addHeader(self.clientSecret!, CLIENT_SECRET)
        request.setJSONRequestBody(deviceData)
        request.setCompletionHandler({(response,error) in
            if(response != nil){
                let responseText = response?.responseText ?? ""
                let status = response?.statusCode ?? 0
                if(status == 200 || status == 201){
                    self.isUserRegistered = true
                    AppLaunchUtils.saveUserContext(userId: userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)
                    AppLaunchUtils.saveValueToNSUserDefaults(value: TRUE, key: IS_USER_REGISTERED)
                    self.userId = userId
                    completionHandler(AppLaunchResponse(status, responseText), nil)
                }else{
                    completionHandler(nil, AppLaunchFailResponse(status, responseText))
                    self.isUserRegistered = false
                }
            }else if let responseError = error{
                completionHandler(nil, AppLaunchFailResponse(500, responseError.localizedDescription))
            }
        })
        request.execute()
        
    }
    
    
    public func unRegisterDevice(completionHandler:@escaping AppLaunchCompletionHandler){
        if(isInitialized) {
            if(AppLaunchUtils.userNeedsToBeRegistered(userId: userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)){
                completionHandler(AppLaunchResponse(500, "Device Not Registered"), nil)
            } else {
                let request = AppLaunchInvoker(url: URLBuilder!.getUserURL(), method: HttpMethod.DELETE, timeout: 60)
                request.addHeader(self.clientSecret!, CLIENT_SECRET)
                request.setCompletionHandler({(response,error) in
                    if(response != nil){
                        let responseText = response?.responseText ?? ""
                        let status = response?.statusCode ?? 0
                        if(status == 204){
                            // Clear registration data and user defaults
                            self.isUserRegistered = false
                            AppLaunchCacheManager.sharedInstance.clearUserDefaults()
                            completionHandler(AppLaunchResponse(status,responseText), nil)
                        }else{
                            completionHandler(nil, AppLaunchFailResponse(status, responseText))
                        }
                    }else if let responseError = error{
                        completionHandler(nil, AppLaunchFailResponse(500,responseError.localizedDescription))
                    }
                })
                request.execute()
            }
        }
    }
    
    /**
     
     This Methode used to get all the available actions from the IBM Cloud AppLaunch service.
     
     - returns: AppLaunchCompletionHandler: A completion-handler callback function. In the case of a successful completion, the actions information is returned in the AppLaunchResponse. In the case of a unsuccessful completion, the error information is returned in the AppLaunchFailResponse
     */
    public func actions(completionHandler:@escaping AppLaunchCompletionHandler){
        
        if(isInitialized && !AppLaunchUtils.userNeedsToBeRegistered(userId: self.userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)){
            
            let request = AppLaunchInvoker(url: (URLBuilder?.getActionURL())!, method: HttpMethod.GET, timeout: 60)
            request.addHeader(self.clientSecret!, CLIENT_SECRET)
            
            request.setCompletionHandler({ (response, error) in
                if response != nil {
                    let status = response?.statusCode ?? 0
                    let responseText = response?.responseText ?? ""
                    
                    if(status == 200 || status == 201){
                        if let data = responseText.data(using: String.Encoding.utf8) {
                            do {
                                let respJson = try JSON(data: data)
                                print("response data from server \(responseText)")
                                AppLaunchCacheManager.sharedInstance.addActions(respJson[FEATURES])
                                AppLaunchCacheManager.sharedInstance.addInAppActionToCache(respJson[INAPP])
                                completionHandler(AppLaunchResponse(200, "", respJson), nil)
                            } catch {
                                completionHandler(nil, AppLaunchFailResponse(404, error.localizedDescription))
                            }
                        }
                    }else{
                        print("[404] Actions Not found")
                        completionHandler(nil, AppLaunchFailResponse(status, responseText))
                    }
                    
                }else {
                    completionHandler(nil, AppLaunchFailResponse(500, MSG__ERR_GET_ACTIONS))
                }
            })
            request.execute()
            
        }else{
            completionHandler(nil, AppLaunchFailResponse(500, MSG__ERR_NOT_REG_NOT_INIT))
            
        }
    }
    
    /**
     Checks if the feature is enabled for the app
     
     - returns
     Bool value
     */
    public func hasFeatureWith(code:String) -> Bool{
        if(AppLaunchCacheManager.sharedInstance.readJSON(code) != JSON.null) {
            return true
        }
        return false
    }
    
    /**
     Returns the value for particular property in a feature
     
     - returns
     String value of the property or Empty string if property/feature doesn't exist
     
     - parameters:
     - featureWithCode: feature code
     - propertyWithCode: property code
     */
    public func getValueFor(featureWithCode:String , propertyWithCode:String) -> String{
        let feature = AppLaunchCacheManager.sharedInstance.readJSON(featureWithCode)
        if (feature != JSON.null) {
            for(_,property) in feature[PROPERTIES]{
                if let propertyCode = property[CODE].string{
                    if propertyCode == propertyWithCode{
                        return property[VALUE].stringValue
                    }
                }
            }
        }
        return ""
    }
    
    /**
     
     This Methode used to send metrics information to the IBM Cloud AppLaunch service.
     
     - Parameter code: This is the metric code value.
     */
    public func sendMetricsWith(code:String) -> Void {
        if(isInitialized && !AppLaunchUtils.userNeedsToBeRegistered(userId: self.userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)){
            
            var metricsData:JSON = JSON()
            metricsData[METRIC_CODES].arrayObject = [code]
            print("metrics payload \(metricsData.description)")
            
            let request = AppLaunchInvoker(url: (URLBuilder?.getMetricsURL())!, method: HttpMethod.POST, timeout: 60)
            request.addHeader(APPLICATION_JSON, CONTENT_TYPE)
            request.addHeader(self.clientSecret!, CLIENT_SECRET)
            request.setJSONRequestBody(metricsData)
            request.setCompletionHandler({(response,error) in
                
                let status = response?.statusCode ?? 0
                if(status == 200){
                    print("sent metrics for code : \(code)")
                }else if let responseError = error{
                    print("Error in sending metrics for code : \(code) with error :\(responseError.localizedDescription)")
                }
                
            })
            request.execute()
        }else{
            print(MSG__ERR_METRICS_NOT_INIT)
        }
        
    }
    
    /**
     
     This Methode returns the InApp Message information from the IBM Cloud AppLaunch service.
     
     - Parameter autoRenderUI: This is the autoRenderUI value.
     
     - returns: AppLaunchCompletionHandler: A completion-handler callback function. In the case of a successful completion, the InApp Messaging information is returned in the AppLaunchResponse. In the case of a unsuccessful completion, the error information is returned in the AppLaunchFailResponse
     */
    public func getInAppContent(autoRenderUI:Bool, completionHandler: @escaping AppLaunchCompletionHandler) -> Void {
        if(isInitialized && !AppLaunchUtils.userNeedsToBeRegistered(userId: self.userId, applicationId: self.applicationId!, deviceId: self.deviceId, region: self.region!)){
            let InAppActions = AppLaunchCacheManager.sharedInstance.readJSON(INAPP)
            if(autoRenderUI){
                for (_, action) in InAppActions {
                    displayInAppMessage(action)
                }
            }else{
                completionHandler(AppLaunchResponse(200, nil, InAppActions), nil)
            }
        }
    }
    
    private func displayInAppMessage(_ action: JSON) -> Void {
        let layout : String = action[LAYOUT].stringValue
        switch(layout){
        case MessageType.Banner.rawValue:
            AppLaunchInAppMessaging(action).ShowBanner()
            break
        default :
            break
        }
    }
    
    private func displayInAppActions() -> Void {
        let InAppActions = AppLaunchCacheManager.sharedInstance.readJSON(INAPP)
        for (_, action) in InAppActions {
            let trigger : String = action[TRIGGERS][0][ACTION].stringValue
            switch(trigger){
            case TriggerType.EveryLaunch.rawValue :
                displayInAppMessage(action)
                break
            case TriggerType.FirstLaunch.rawValue :
                let previousDateString = AppLaunchCacheManager.sharedInstance.readString(trigger).isEmpty ? "0" : AppLaunchCacheManager.sharedInstance.readString(trigger)
                let previousDate = Int(previousDateString)!
                let currentDate = AppLaunchUtils.getCurrentDate()
                // Check if date changed or not
                if(currentDate > previousDate) {
                    displayInAppMessage(action)
                    AppLaunchCacheManager.sharedInstance.addString(String(AppLaunchUtils.getCurrentDate()), trigger)
                }
                break
            case TriggerType.EveryAlternateLaunch.rawValue :
                if(AppLaunchCacheManager.sharedInstance.readString(trigger).isEmpty) {
                    displayInAppMessage(action)
                    AppLaunchCacheManager.sharedInstance.addString(trigger, trigger)
                } else {
                    AppLaunchCacheManager.sharedInstance.clearString(trigger)
                }
                break
            case TriggerType.OnceAndOnlyOnce.rawValue :
                if(AppLaunchCacheManager.sharedInstance.readString(trigger).isEmpty) {
                    displayInAppMessage(action)
                    AppLaunchCacheManager.sharedInstance.addString(trigger, trigger)
                }
                break
            default :
                break
            }
            displayInAppMessage(action)
        }
    }
    
    
}
