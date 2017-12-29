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
    
    private let action: MessageData
    
    init(_ data: JSON) {
        self.action = MessageData.init(data[TITLE].stringValue, data[SUB_TITLE].stringValue, data[IMAGE_URL].stringValue, data["layout"].stringValue, data["buttons"]);
    }
    
    func ShowBanner() -> Void {
        var imageData:NSData
        do {
            if(!action.getImageUrl().isEmpty){
                imageData = try NSData(contentsOf: URL(string: action.getImageUrl())!)
            }else{
                imageData = NSData()
            }
        } catch  {
            imageData = NSData()
        }
        
        let alertVC = PMAlertController(title: action.getTitle(), description: action.getSubTitle(), image: UIImage(data: imageData as Data ), style: .walkthrough)  //.alert is smaller version
        
        for button in action.getButtonDataList() {
            alertVC.addAction(PMAlertAction(title: button.getButtonName(), style: .default, action: { () -> Void in
                let buttonType = "invoke-function"
                switch(buttonType){
                case "navigate":
                    break
                case "invoke-function":
                    let metric = button.getMetrics()
                    print(metric[0][CODE])
                    AppLaunch.sharedInstance.sendMetricsWith(code: metric[0][CODE].stringValue)
                    break
                default: break
                }
            }))
        }
        
        alertVC.show()
    }
}


internal enum MessageType : String {
    case Banner = "banner"
}

internal class MessageData {
    private var imageUrl:String
    private var title:String
    private var subTitle:String
    private var buttonData:[ButtonData]?
    private var layout:String
    
    init(_ title:String,_ subTitle:String,_ imageUrl:String,_ layout:String,_ buttonData:JSON) {
        self.title = title
        self.subTitle = subTitle
        self.imageUrl = imageUrl
        self.layout = layout
        self.buttonData = processButtons(buttonData)
    }
    
    private func processButtons(_ data: JSON) -> [ButtonData]{
        var list = [ButtonData]()
        for (_, b1) in data {
            let button = ButtonData.init(b1[NAME].stringValue, b1[ACTION].stringValue, b1[METRICS])
            list.append(button)
        }
        return list
    }

    
    func getImageUrl() -> String {
        return imageUrl
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getSubTitle() -> String {
        return subTitle
    }
    
    func getButtonDataList() -> [ButtonData]{
        return buttonData!
    }
    
}


internal class ButtonData {
    
    private var buttonName:String
    private var action:String
    private var metrics:JSON
    
    init(_ buttonName:String, _ action:String, _ metrics:JSON) {
        self.buttonName = buttonName
        self.action = action
        self.metrics = metrics
    }
   
    func getButtonName() -> String {
    return buttonName
    }
    
    func getMetrics() -> JSON {
    return metrics
    }
    
    func getAction() -> String {
    return action
    }
    
}
