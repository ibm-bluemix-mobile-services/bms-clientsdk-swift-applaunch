//
//  AppLaunchCacheManager.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON


internal class AppLaunchCacheManager {
    static let sharedInstance = AppLaunchCacheManager()
    fileprivate let lock = NSLock()
    private let userDefaults = UserDefaults.standard
    private let JSON_PATH_EXTENSION:String = ".json"
    private let JSON_NAME:String = "json"
    private let SERVICE_NAME:String = "AppLaunch"
    
    /**
     * Add the string value to the local cache with the given key
     * @param key
     * @param value
     */
    func addString(_ value:String,_ key:String) -> Void{
        userDefaults.set(value,forKey: key)
        userDefaults.synchronize()
    }
    
    func readString(_ key:String) -> String {
        if (userDefaults.value(forKey: key) != nil) {
            return userDefaults.value(forKey: key) as! String
        }
        return ""
    }
    
    func clearString(_ key:String) -> Void {
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }
    
    func clearUserDefaults() -> Void {
       // Clears registration data and features from User defaults
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    func readJSON(_ key: String) -> JSON{
        if (userDefaults.object(forKey: key) != nil) {
            let data = userDefaults.object(forKey: key) as! String
            return JSON.init(parseJSON: data)
        }
        return JSON.null
    }
    
    func loadDefaultFeatures() -> Void {
        let fileManager = FileManager.init();
        let applicationPath = Bundle.main.bundlePath;
        do {
            let filesList = try fileManager.contentsOfDirectory(atPath: applicationPath);
            let filteredfileList = filesList.filter { file in
                return (file.lowercased().hasPrefix(SERVICE_NAME) && file.lowercased().hasSuffix(JSON_PATH_EXTENSION))
            }
            for file in filteredfileList {
                let JSON = getFeatureFromFile(fileName: file)
                addActionToCache(JSON!)
            }
        } catch {
            print(error)
        }
    }
    
    func addActions(_ actions: JSON){
        for (_, action) in actions {
            addActionToCache(action)
        }
    }
    
    private func addActionToCache(_ action: JSON) -> Void{
        lock.lock()
        defer {lock.unlock()}
        if (action != JSON.null) {
            addString(action.rawString()!,action[CODE].string!)
        }
    }
    
    private func getFeatureFromFile(fileName: String) -> JSON? {
        let filePath = Bundle.main.url(forResource: fileName.replacingOccurrences(of: JSON_PATH_EXTENSION, with: ""), withExtension: JSON_NAME)
        if (filePath != nil && validateFilePath(filePath!)) {
            do {
                let data = try Data(contentsOf: filePath!, options: .alwaysMapped)
                return validateFeatureContent(data);
            } catch let error {
                print("parse error: \(error.localizedDescription)")
            }
        } else{
            print("Invalid filename/path.")
        }
        return nil;
    }
    
    private func validateFilePath(_ path: URL) -> Bool {
        do {
            return try path.checkResourceIsReachable()
        }
        catch {
            // File doesn't exist
            return false
        }
    }
    
    private func validateFeatureContent(_ Data: Data) -> JSON {
        do {
            let feature = try JSON(data: Data);
            if(feature[NAME].exists() && feature[CODE].exists()){
                return feature;
            }
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
        return JSON.null
    }
}
