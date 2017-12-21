//
//  AppLaunchInAppMessaging.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON

internal class AppLaunchInAppMessaging: NSObject {
    
    private let data: JSON
    
    init(_ data: JSON) {
        self.data = data;
    }
    
    func ShowBanner() -> Void {
        let title : String = data[CONTENT][0][TITLE].stringValue
        let content : String = data[CONTENT][0][SUB_TITLE].stringValue
        let imageUrl : String = data[CONTENT][0][IMAGE_URL].stringValue
        
        let leftButtonText : String = data[BUTTONS][0][BUTTON_NAME].stringValue
        let rightButtonText : String = data[BUTTONS][1][BUTTON_VALUE].stringValue
        
        let leftButtonType:String = data[BUTTONS][0][BUTTON_TYPE].stringValue
        let rightButtonType:String = data[BUTTONS][1][BUTTON_TYPE].stringValue
        
        let leftButtonValue:String = data[BUTTONS][0][BUTTON_TYPE].stringValue
        let rightButtonValue:String = data[BUTTONS][1][BUTTON_TYPE].stringValue

        var imageData:NSData
        do {
            if(!imageUrl.isEmpty){
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
                //self.performSelector(onMainThread: leftButtonSelector, with: nil, waitUntilDone: true)
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
}


internal enum MessageType : String {
    case Banner = "Banner"
}

internal class MessageData {
    private var imageUrl:String
    private var title:String
    private var subTitle:String
    private var buttonDataList:String
    private var metric:String
    private var messageType:String
    
    init(_ title:String,_ subTitle:String,_ imageUrl:String,_ messageType:String,_ buttonDataList:String,_ metric:String) {
        self.title = title
        self.subTitle = subTitle
        self.imageUrl = imageUrl
        self.messageType = messageType
        self.buttonDataList = buttonDataList
        self.metric = metric
    }
    
    internal func getImageUrl() -> String {
        return imageUrl;
    }
    
    internal func getTitle() -> String {
        return title;
    }
    
    internal func getSubTitle() -> String {
        return subTitle;
    }
    
    internal func getButtonDataList() -> String{
        return buttonDataList;
    }
    
}
