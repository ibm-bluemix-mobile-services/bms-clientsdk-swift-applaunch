//
//  Engage.swift
//  Engage
//
//  Created by Chethan Kumar on 3/14/17.
//  Copyright © 2017 Chethan Kumar. All rights reserved.
//

import Foundation
import AVFoundation
import BMSCore


public class Engage:NSObject{
    
    private let VERY_ACTIVE : String = "VERY_ACTIVE"
    private let ACTIVE : String = "ACTIVE"
    private let PASSIVE : String = "PASSIVE"
    private let OCCASSIONAL : String = "OCCASSIONAL"
    private let FIRST_RUN : String = "FIRST_RUN"
    private let url:String = "http://localhost:8080/api/v1"
    //    private let url:String = "https://engagement-service.mybluemix.net"
    
//    private let REGISTRATION_SERVER:String = "http://bms-engage-registration-server-dev.stage1.ng.bluemix.net/api/v1"
    private let REGISTRATION_SERVER:String = "http://localhost:18000/api/v1"
    private let CLIENT_ACTIVITY_SERVER:String = "https://bms-engage-activity-analyzer-dev.stage1.ng.bluemix.net/api/v1"
    
    private let SERVICE_INSTANCE_ID:String = "serviceInstanceId"
    private let OS_TYPE:String = "OSType"
    private let IOS:String = "iOS"
    private let DEVICE_ID:String = "deviceId"
    private let LOCALE:String = "locale"
    private let APP_USED_ON_DATES:String = "appUsedOnDates"
    
    private let BUTTON_NAME:String = "buttonName"
    private let BUTTON_TYPE:String = "buttonType"
    private let BUTTON_VALUE:String = "buttonValue"
    
    private let INVOKE_FUNCTION:String = "invoke-function"
    private let NAVIGATE:String = "navigate"
    
    private let USER_ID:String = "userId"
    private let ID:String = "id"
    
    private var devId = String()
    
    public static let sharedInstance = Engage()
    
    // Specifies the bluemix push clientSecret value
    public private(set) var clientSecret: String?
    public private(set) var applicationId: String?
    
    /// `BMSClient` object.
    private var bmsClient = BMSClient.sharedInstance
    
    private var isInitialized = false
    
    private var isUserRegistered = false
    
    private var userId:String = ""
    
    private var audioPlayer = AVAudioPlayer()
    
    public func initializeWithAppGUID (applicationId: String, clientSecret: String) {
        
        if validateString(object: clientSecret) {
            self.clientSecret = clientSecret
            self.applicationId = applicationId
            isInitialized = true;
            
            let authManager  = BMSClient.sharedInstance.authorizationManager
            devId = authManager.deviceIdentity.ID!
            CaptivateUtils.saveValueToNSUserDefaults(value: devId, key: "deviceId")
            
        }
        else{
            
            print("Error while registration - Client secret is not valid")
        }
    }
    
    public func registerWith(userId:String,completionHandler:@escaping(_ response:String, _ statusCode:Int, _ error:String) -> Void){
        if(isInitialized){
            var deviceData:JSON = JSON()
            deviceData["deviceId"].string = devId
            deviceData["model"].string = UIDevice.current.modelName
            deviceData["brand"].string = "Apple"
            deviceData["OSVersion"].string = UIDevice.current.systemVersion
            deviceData["platform"].string = "iOS"
            deviceData["appId"].string = Bundle.main.bundleIdentifier!
            deviceData["appVersion"].string = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            deviceData["appName"].string = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
            deviceData["userId"].string = userId
            
            let userRegUrl = REGISTRATION_SERVER+"/apps/\(self.applicationId!)/users"
            
            var  headers = [String:String]()
            headers.updateValue("application/json; charset = UTF-8", forKey: "Content-Type")
            
            let createUserRequest = Request(url: userRegUrl, method: HttpMethod.POST,headers: headers, queryParameters: nil, timeout: 60)
            
            createUserRequest.send(requestBody: deviceData.description.data(using: .utf8),completionHandler:{(response,error) in
                
                if(response != nil){
                    let responseText = response?.responseText ?? ""
                    let status = response?.statusCode ?? 0
                    if(status == 400){
                        completionHandler("", status, responseText)
                        self.isUserRegistered = false
                    }else{
                        self.isUserRegistered = true
                        self.userId = userId
                        completionHandler(responseText,status,"")
                        
                    }
                }else if let responseError = error{
                    completionHandler("", 500, responseError.localizedDescription)
                }
            })
        }
    }
    
    public func updateUserWith(userId:String,attribute:String,value:Any, completionHandler:@escaping(_ response:String, _ statusCode:Int, _ error:String) -> Void){
        
        var deviceData:JSON = JSON()
        deviceData["deviceId"].string = devId
        deviceData["userId"].string = userId
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
        
        
        let userRegUrl = REGISTRATION_SERVER+"/apps/\(self.applicationId!)/users/\(userId)"
        
        var  headers = [String:String]()
        headers.updateValue("application/json; charset = UTF-8", forKey: "Content-Type")
        
        let createUserRequest = Request(url: userRegUrl, method: HttpMethod.PUT,headers: headers, queryParameters: nil, timeout: 60)
        
        createUserRequest.send(requestBody: deviceData.description.data(using: .utf8),completionHandler:{(response,error) in
            
            if(response != nil){
                let responseText = response?.responseText ?? ""
                let status = response?.statusCode ?? 0
                if(status == 400){
                    completionHandler("", status, responseText)
                    self.isUserRegistered = false
                }else{
                    self.isUserRegistered = true
                    self.userId = userId
                    completionHandler(responseText,status,"")
                    
                }
            }else if let responseError = error{
                completionHandler("", 500, responseError.localizedDescription)
            }
        })
    }
    
    
    
//    public func registerFunction(identifier:String,functionName:String, completionHandler:@escaping(_ response:String, _ statusCode:Int, _ error:String) -> Void){
//
//        if (isInitialized){
//            let resourceURL:String = url+"/buttonconfig"
//
//            var  headers = [String:String]()
//            headers.updateValue("application/json; charset = UTF-8", forKey: "Content-Type")
//
//
//            let createButtonRequest = Request(url: resourceURL, method: HttpMethod.POST,headers: headers, queryParameters: nil, timeout: 60)
//
//            let data =  "{\"\(SERVICE_INSTANCE_ID)\":\"\(applicationId!)\",\"\(BUTTON_NAME)\":\"\(identifier)\", \"\(BUTTON_TYPE)\":\"\(INVOKE_FUNCTION)\", \"\(BUTTON_VALUE)\":\"\(functionName)\"}".data(using: .utf8)
//
//            createButtonRequest.send(requestBody: data, completionHandler: { (response, error) in
//
//                if(response != nil){
//                    let responseText = response?.responseText ?? ""
//                    let status = response?.statusCode ?? 0
//                    if(status == 400){
//                        completionHandler("", status, responseText)
//                    }else{
//                        completionHandler(responseText,status,"")
//                    }
//
//                }else if let responseError = error{
//                    completionHandler("", 500, responseError.localizedDescription)
//                }
//            })
//
//        }else{
//            completionHandler("", 500, "Captivate SDK not initialized");
//        }
//
//    }
    
    public func getDynamicContent(autoRenderUI:Bool, completionHandler:@escaping(_ response:[String:Any]?, _ statusCode:Int?, _ error:String) -> Void){
        if (isInitialized){
            
            //TODO build url for different bluemix zones and envs
            let resourceURL:String = url+"/captivateengine/inappmsg"
            
            //TODO add client secret in headers
            var  headers = [String:String]()
            headers.updateValue("application/json; charset = UTF-8", forKey: "Content-Type")
            
            var queryParam = [String:String]()
            queryParam.updateValue(isFirstRun(), forKey: "isFirstRun")
            //            queryParam.updateValue("VERY_ACTIVE", forKey: "userType")
            queryParam.updateValue(devId, forKey: "deviceId")
            //            queryParam.updateValue(Bundle.main.bundleIdentifier!, forKey: "bundleId")
            queryParam.updateValue(applicationId!, forKey: "serviceInstanceId")
            queryParam.updateValue("en", forKey: "locale")
            queryParam.updateValue("iOS", forKey: "OSType")
            
            let getMessageRequest = Request(url: resourceURL, method: HttpMethod.GET,headers: headers, queryParameters: queryParam, timeout: 60)
            
            getMessageRequest.send(completionHandler: { (response, error) in
                if response?.statusCode != nil {
                    let status = response?.statusCode ?? 0
                    let responseText = response?.responseText ?? ""
                    
                    if(status == 404){
                        print("[404] Not found")
                    }else{
                        //Finally got the content! Now to render or not render the message
                        let respJson = CaptivateUtils.convertToDictionary(text:responseText)
                        print("response data from server \(response?.responseText)")
                        var data : JSON = JSON(respJson)
                        
                        if(autoRenderUI){
                            let template : String = data["templateType"].stringValue
                            
                            switch(template){
                            case "banner":
                                self.showBanner(json: data, frequency: "")
                                break
                                
                            case "top-slice":
                                self.showTopSlice(json: data, frequency: "")
                                break
                                
                            case "voice-over":
                                self.playVoice(json: data, frequency: "")
                                break
                                
                            case "user-onboarding":
                                self.onboardUser(json: data, frequency: "")
                                break
                                
                            default :
                                break
                            }
                        }else{
                            completionHandler(respJson,200,"")
                        }
                    }
                    
                }else {
                    completionHandler([:], 500 , "Error while getting message from captivate service")
                }
            })
            
            
            
            
            
        }else{
            completionHandler([:], 500 , "Error while registration - BMSPush is not initialized")
        }
    }
    
    public func getFeatures(completionHandler:@escaping(_ response:JSON?, _ statusCode:Int?, _ error:String) -> Void){
        
        if(isInitialized && isUserRegistered){
            
            CaptivateUtils.saveValueToNSUserDefaults(value: devId, key: "deviceId")
            
            //TODO build url for different bluemix zones and envs
            let resourceURL:String = CLIENT_ACTIVITY_SERVER+"/apps/\(self.applicationId!)/users/\(self.userId)/actions/features"
            
            //TODO add client secret in headers
            let headers = ["Content-Type" : "application/json; charset = UTF-8"]
            
            let getfeaturesRequest = Request(url: resourceURL, method: HttpMethod.GET,headers: headers, queryParameters: nil, timeout: 60)
            
            
            getfeaturesRequest.send(completionHandler: { (response, error) in
                if response?.statusCode != nil {
                    let status = response?.statusCode ?? 0
                    let responseText = response?.responseText ?? ""
                    
                    if(status == 404){
                        print("[404] Not found")
                    }else{
                        if let data = responseText.data(using: String.Encoding.utf8) {
                            let respJson = JSON(data: data)
                            
                            print("response data from server \(response?.responseText)")
                            completionHandler(respJson,nil,"")
                        }
                    }
                    
                }else {
                    completionHandler([], 500 , "Error while getting features")
                }
            })
            
        }else{
            completionHandler([], 500 , "Error while getting features. Engage is not initialized or the user is not registered. Register the user before requesting for features")
            
        }
        
    }
    
    public func sendMetricsWith(code:String) -> Void{
        if(isInitialized && isUserRegistered){
            
            var metricsData:JSON = JSON()
            metricsData["deviceId"].string = devId
            metricsData["userId"].string = userId
            metricsData["metricCode"].string = code
            
            let resourceURL:String = CLIENT_ACTIVITY_SERVER+"/apps/\(self.applicationId!)/users/\(userId)/events/metrics"
            
            //TODO add client secret in headers
            let headers = ["Content-Type" : "application/json; charset = UTF-8"]
            
            let metricsRequest = Request(url: resourceURL, method: HttpMethod.POST,headers: headers, queryParameters: nil, timeout: 60)
            
            metricsRequest.send(requestBody: metricsData.description.data(using: .utf8),completionHandler:{(response,error) in
                
                let status = response?.statusCode ?? 0
                if(status == 200){
                    print("sent metrics for code : \(code)")
                }else if let responseError = error{
                    print("Error in sending metrics for code : \(code) with error :\(responseError.localizedDescription)")
                }
                
            })
        }else{
            print("Error while sending metrics. Engage is not initialized or the user is not registered. Register the user before sending metrics")
        }
        
    }
    
    public func getAppThemeConfig(completionHandler:@escaping(_ response:[String:Any]?, _ statusCode:Int?, _ error:String) -> Void){
        
        if(isInitialized){
            var devId = String()
            let authManager  = BMSClient.sharedInstance.authorizationManager
            devId = authManager.deviceIdentity.ID!
            CaptivateUtils.saveValueToNSUserDefaults(value: devId, key: "deviceId")
            
            //TODO build url for different bluemix zones and envs
            let resourceURL:String = url+"/captivateengine/apptheme"
            
            //TODO add client secret in headers
            let headers = ["Content-Type" : "application/json; charset = UTF-8"]
            
            var queryParam = [String:String]()
            queryParam.updateValue(devId, forKey: "deviceId")
            queryParam.updateValue(applicationId!, forKey: "serviceInstanceId")
            queryParam.updateValue("en", forKey: "locale")
            queryParam.updateValue("iOS", forKey: "OSType")
            
            
            let getAppThemeRequest = Request(url: resourceURL, method: HttpMethod.GET,headers: headers, queryParameters: queryParam, timeout: 60)
            
            
            getAppThemeRequest.send(completionHandler: { (response, error) in
                if response?.statusCode != nil {
                    let status = response?.statusCode ?? 0
                    let responseText = response?.responseText ?? ""
                    
                    if(status == 404){
                        print("[404] Not found")
                    }else{
                        let respJson = CaptivateUtils.convertToDictionary(text: responseText)
                        print("response data from server \(response?.responseText)")
                        completionHandler(respJson,nil,"")
                    }
                    
                }else {
                    completionHandler([:], 500 , "Error while getting message from captivate service")
                }
            })
            
        }else{
            completionHandler([:], 500 , "Error while registering - BMSPush is not initialized")
            
        }
        
    }
    
    public func getJSONConfig(completionHandler:@escaping(_ response:JSON?, _ statusCode:Int?, _ error:String) -> Void){
        
        if(isInitialized){
            var devId = String()
            let authManager  = BMSClient.sharedInstance.authorizationManager
            devId = authManager.deviceIdentity.ID!
            CaptivateUtils.saveValueToNSUserDefaults(value: devId, key: "deviceId")
            
            //TODO build url for different bluemix zones and envs
            let resourceURL:String = url+"/captivateengine/jsonconfig"
            
            //TODO add client secret in headers
            let headers = ["Content-Type" : "application/json; charset = UTF-8"]
            
            var queryParam = [String:String]()
            queryParam.updateValue(devId, forKey: "deviceId")
            queryParam.updateValue(applicationId!, forKey: "serviceInstanceId")
            queryParam.updateValue("en", forKey: "locale")
            queryParam.updateValue("iOS", forKey: "OSType")
            
            
            let getfeaturesRequest = Request(url: resourceURL, method: HttpMethod.GET,headers: headers, queryParameters: queryParam, timeout: 60)
            
            
            getfeaturesRequest.send(completionHandler: { (response, error) in
                if response?.statusCode != nil {
                    let status = response?.statusCode ?? 0
                    let responseText = response?.responseText ?? ""
                    
                    if(status == 404){
                        print("[404] Not found")
                    }else{
                        if let data = responseText.data(using: String.Encoding.utf8) {
                            let json = JSON(data: data)
                            print("response data from server \(response?.responseText)")
                            completionHandler(json,nil,"")
                        }
                    }
                    
                }else {
                    completionHandler([], 500 , "Error while getting message from captivate service")
                }
            })
            
        }else{
            completionHandler([], 500 , "Error while registering - BMSPush is not initialized")
            
        }
        
    }
    
    
    internal func showBanner(json: JSON, frequency: String){
        
        let title : String = json["content"][0]["title"].stringValue
        let content : String = json["content"][0]["subTitle"].stringValue
        let imageUrl : String = json["content"][0]["imageUrl"].stringValue
        
        let leftButtonText : String = json["buttons"][0]["buttonName"].stringValue
        let rightButtonText : String = json["buttons"][1]["buttonName"].stringValue
        
        let leftButtonType:String = json["buttons"][0]["buttonType"].stringValue
        let rightButtonType:String = json["buttons"][1]["buttonType"].stringValue
        
        let leftButtonValue:String = json["buttons"][0]["buttonValue"].stringValue
        let rightButtonValue:String = json["buttons"][1]["buttonValue"].stringValue
        
        var imageData:NSData
        do {
            if(imageUrl != ""){
                imageData = try NSData(contentsOf: URL(string: imageUrl)!)
            }else{
                imageData = NSData()
            }
        } catch  {
            imageData = NSData()
        }
        
        let alertVC = PMAlertController(title: title, description: content, image: UIImage(data: imageData as Data ), style: .walkthrough)  //.alert is smaller version
        
        alertVC.addAction(PMAlertAction(title: leftButtonText, style: .cancel, action: { () -> Void in
            print("Left button clicked")
            switch(leftButtonType){
            case "navigate":
                break
            case "invoke-function":
                let leftButtonSelector:Selector = Selector(leftButtonValue)
                self.performSelector(onMainThread: leftButtonSelector, with: nil, waitUntilDone: true)
                break
            default: break
            }
        }))
        
        alertVC.addAction(PMAlertAction(title: rightButtonText, style: .cancel, action: { () -> Void in
            print("Left button clicked")
            switch(leftButtonType){
            case "navigate":
                break
            case "invoke-function":
                break
            default: break
            }
        }))
        
        alertVC.show()
    }
    
    internal func playVoice(json: JSON, frequency: String){
        //Play the voice over from using watson service.
        
        let title : String = json["content"][0]["title"].stringValue
        let content : String = json["content"][0]["subTitle"].stringValue
        let imageUrl : String = json["content"][0]["imageUrl"].stringValue
        let button1Text :String = "ok"
        //        let button1Text : String = json["message"]["button1Text"].stringValue
        
        let username = "f92501ea-88b1-4fe4-ad26-6967f006e511"
        let password = "6eXG03EjiRb6"
        let textToSpeech = TextToSpeech(username: username, password: password)
        
        var imageData:NSData
        do {
            if(imageUrl != ""){
                imageData = try NSData(contentsOf: URL(string: imageUrl)!)
            }else{
                imageData = NSData()
            }
        } catch  {
            imageData = NSData()
        }
        
        let alertVC = PMAlertController(title: title, description: "", image: UIImage(data: imageData as Data ), style: .walkthrough)  //.alert is smaller version
        
        alertVC.addAction(PMAlertAction(title: button1Text, style: .cancel, action: { () -> Void in
            print("Capture action Cancel")
        }))
        
        alertVC.show()
        
        //now play the voice
        let failure = { (error: Error) in print("error in playing voice \(error)") }
        
        textToSpeech.synthesize(content, failure: failure) { data in
            print("Got data. Playing sound")
            self.audioPlayer = try! AVAudioPlayer(data: data)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
        }
    }
    
    internal func onboardUser(json: JSON, frequency: String){
        //Onboard user
        
        var arrayOfImage = [String]()
        var arrayOfTitle = [String]()
        var arrayOfDescription = [String]()
        
        for item in json["content"].arrayValue {
            arrayOfTitle.append(item["title"].stringValue)
            arrayOfDescription.append(item["subTitle"].stringValue)
            arrayOfImage.append(item["imageUrl"].stringValue)
        }
        
        
        //Simply call AlertOnboarding...
        let alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
        
        //... and show it !
        alertView.show()
        
    }
    
    internal func showTopSlice(json: JSON, frequency: String){
        let title : String = json["content"][0]["title"].stringValue
        let content : String = json["content"][0]["subTitle"].stringValue
        let imageUrl : String = json["content"][0]["imageUrl"].stringValue
        
        var imageData:NSData
        do {
            if(imageUrl != ""){
                imageData = try NSData(contentsOf: URL(string: imageUrl)!)
            }else{
                imageData = NSData()
            }
        } catch  {
            imageData = NSData()
        }
        
        HDNotificationView.show(with: UIImage(data: imageData as Data ), title: title, message: content)
    }
    
    internal func isFirstRun() -> String{
        if(UserDefaults.standard.bool(forKey: FIRST_RUN)){
            return "false"
        }else{
            UserDefaults.standard.setValue(true, forKeyPath: FIRST_RUN)
            return "true"
        }
    }
    
    internal func validateString(object:String) -> Bool{
        if (object.isEmpty || object == "") {
            return false;
        }
        return true
    }
    
}
