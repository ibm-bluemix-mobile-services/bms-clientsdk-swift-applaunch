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
    
    class func loadFeatureFromFiles() -> JSON? {
        lock.lock()
        defer {lock.unlock()}
        let cache = Cache()
        return cache.loadFiles()
    }
    
    class func saveJSON(Data: JSON) {
        lock.lock()
        defer {lock.unlock()}
        let cache = Cache()
        cache.save(Data)
    }
    
    
    internal class Cache {
        
        func loadFiles() -> JSON? {
            let configfilenames = readJSONConfigFiles()
            var features: [JSON] = [JSON]()
            for file in configfilenames! {
                let JSON = readJSONfrom(fileName: file)
                features.append(JSON!)
            }
            return JSON(features);
        }
        
        func save(_ Data: JSON) {
            lock.lock()
            defer {lock.unlock()}
            for (_, feature) in Data {
                updateJSONwith(Data: feature, Name: feature["name"].string!)
            }
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
        
        private func updateJSONwith(Data: JSON, Name: String) {
            let fileName = SERVICE_NAME + Name;
            let path = Bundle.main.url(forResource: fileName, withExtension: JSON_NAME)
            if (path != nil) {
                do {
                    let rawData = try Data.rawData();
                    try rawData.write(to: path!)
                    
                } catch let error {
                    print("Write error: \(error.localizedDescription)")
                }
            } else {
                print("Invalid filename/path.")
            }
        }
        
        private func readJSONfrom(fileName: String) -> JSON? {
            let filePath = Bundle.main.path(forResource: fileName.replacingOccurrences(of: JSON_PATH_EXTENSION, with: ""), ofType: JSON_NAME);
            if (filePath != nil) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: filePath!), options: .alwaysMapped)
                    return try JSON(data: data);
                } catch let error {
                    print("parse error: \(error.localizedDescription)")
                }
            } else{
                print("Invalid filename/path.")
            }
            return nil;
        }
        
        private func validateJSON(Data: JSON) -> Bool {
            if(Data[NAME].exists() && Data[CODE].exists()){
                return true;
            }
            print("Invalid AppLaunch JSON File")
            return false;
        }
    }
    
    
}
