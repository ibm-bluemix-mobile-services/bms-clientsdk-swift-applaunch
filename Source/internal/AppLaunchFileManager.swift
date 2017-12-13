//
//  AppLaunchFileManager.swift
//  AppLaunch
//
//  Created by Vittal Pai on 12/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON


internal class AppLaunchFileManager {
    
    fileprivate static let lock = NSLock()
    
    class func loadFeatureFromFiles() {
        lock.lock()
        defer {lock.unlock()}
        let cache = Cache()
        cache.loadFiles()
    }
    
    class func loadFeatures() -> JSON {
        lock.lock()
        defer {lock.unlock()}
        let cache = Cache()
        return cache.loadFeatures()
    }
    
    class func saveFeatures(data: JSON) {
        lock.lock()
        defer {lock.unlock()}
        let cache = Cache()
        cache.saveMultipleFeatures(data)
    }
    
    class func save(feature: JSON){
        lock.lock()
        defer {lock.unlock()}
        let cache = Cache()
        cache.save(feature)
    }
    
    class func read(featureId: String) -> JSON {
        lock.lock()
        defer {lock.unlock()}
        let cache = Cache()
        return cache.read(featureId)
    }
    
    internal class Cache {
        
        private let userDefaults = UserDefaults.standard
        
        func loadFiles() -> Void {
            let configfilenames = readJSONConfigFiles()
            for file in configfilenames! {
                let JSON = readJSONfrom(fileName: file)
                save(JSON!)
            }
        }
        
        func loadFeatures() -> JSON {
            var feature = [JSON]()
            let featurecodes = userDefaults.stringArray(forKey: FEATURES)
            for code in featurecodes! {
                feature.append(read(code))
            }
            return JSON(feature)
        }
        
        func read(_ featureId: String) -> JSON{
            let data = userDefaults.object(forKey: featureId) as! String
            return JSON.init(parseJSON: data)
        }
        
        func saveMultipleFeatures(_ features: JSON){
            for (_, feature) in features {
                save(feature)
            }
        }
        
        func save(_ feature: JSON){
            userDefaults.set(feature.rawString(),forKey: feature[CODE].string!)
            userDefaults.synchronize()
        }
        
        
        // TODO : Handle Duplicate files & Optimize logic to fetch only JSON files
        private func readJSONConfigFiles() -> [String]? {
            let fileManager = FileManager.init();
            let applicationPath = Bundle.main.bundlePath;
            do {
                let filesList = try fileManager.contentsOfDirectory(atPath: applicationPath);
                let filteredfileList = filesList.filter { file in
                    if (file.lowercased().hasPrefix(SERVICE_NAME) && file.lowercased().hasSuffix(JSON_PATH_EXTENSION)) {
                        return self.validateJSON(Data: self.readJSONfrom(fileName: file)!);
                    }
                    return false;
                }
                return filteredfileList;
            } catch {
                print(error)
            }
            return nil;
        }
        
        private func readJSONfrom(fileName: String) -> JSON? {
            let filePath = Bundle.main.url(forResource: fileName.replacingOccurrences(of: JSON_PATH_EXTENSION, with: ""), withExtension: JSON_NAME)
            if (filePath != nil && validateFilePath(filePath!)) {
                do {
                    let data = try Data(contentsOf: filePath!, options: .alwaysMapped)
                    return try JSON(data: data);
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
        
        private func validateJSON(Data: JSON) -> Bool {
            if(Data[NAME].exists() && Data[CODE].exists()){
                return true;
            }
            // Invalid JSON File
            return false;
        }
    }
    
}
