/*
*     Copyright 2016 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/


import BMSCore
import BMSAnalyticsAPI
import SwiftyJSON



// MARK: - Swift 3

/**
    Adds the `send` method.
*/
internal extension Logger {
    
    
    internal static var currentlySendingLoggerLogs = false
    internal static var currentlySendingAnalyticsLogs = false
    
    
    /**
        Send the accumulated logs to the Mobile Analytics service.

        Logger logs can only be sent if the BMSClient was initialized with `BMSClient.sharedInstance.initialize(bluemixRegion:)` from the `BMSCore` framework.

        - parameter completionHandler:  Optional callback containing the results of the send request.
    */
    internal static func send(completionHandler userCallback: BMSCompletionHandler? = nil) {
        
        guard !currentlySendingLoggerLogs else {
            
            AppLaunchLogger.internalLogger.info(message: "Ignoring Logger.send() until the previous send request finishes.")
            
            return
        }
        
        currentlySendingLoggerLogs = true
            
        // Internal completion handler - wraps around the user supplied completion handler (if supplied)
        let logSendCallback: BMSCompletionHandler = { (response: Response?, error: Error?) in
            
            currentlySendingLoggerLogs = false
            
            if error == nil && response?.statusCode == 202 {
                
                AppLaunchLogger.internalLogger.debug(message:"Client logs successfully sent to the server.")
                
                AppLaunchLogger.delete(file: Constants.File.Logger.outboundLogs)
                
                // Remove the uncaught exception flag since the logs containing the exception(s) have just been sent to the server
                UserDefaults.standard.set(false, forKey: Constants.uncaughtException)
            }
            else {
                
                var debugMessage = ""
                if let response = response {
                    if let statusCode = response.statusCode {
                        debugMessage += "Status code: \(statusCode). "
                    }
                    if let responseText = response.responseText {
                        debugMessage += "Response: \(responseText). "
                    }
                }
                if let error = error {
                    debugMessage += " Error: \(error)."
                }
                
                if error.debugDescription == "Optional(AppLaunchAnalytics.AppLaunchAnalyticsError.noLogsToSend)" {
                    AppLaunchLogger.internalLogger.error(message: "There are no recorded logs to send to Bluemix.")
                } else {
                    AppLaunchLogger.internalLogger.error(message: "Request to send client logs has failed. To see more details, set Logger.sdkDebugLoggingEnabled to true, or send the logs with a completion handler to retrieve the response and error. Reason: \(debugMessage)")
                }
                AppLaunchLogger.internalLogger.debug(message: debugMessage)
            }
            
            userCallback?(response, error)
        }
    
        // Use a serial queue to ensure that the same logs do not get sent more than once
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
            do {
                // Gather the logs and put them in a JSON object
                if let logsToSend: String = try AppLaunchLogger.getLogs(fromFile: Constants.File.Logger.logs, overflowFileName: Constants.File.Logger.overflowLogs, bufferFileName: Constants.File.Logger.outboundLogs) {
                     var logPayloadJson = JSON()
                     logPayloadJson[Constants.outboundLogPayload].stringValue =  logsToSend
                   
                    let request = AppLaunchInvoker(url: AppLaunchAnalytics.url!, method: HttpMethod.POST, timeout: 60)
                    request.addHeader(APPLICATION_JSON, CONTENT_TYPE)
                    request.addHeader(AppLaunchAnalytics.clientSecret!, CLIENT_SECRET)
                    request.setJSONRequestBody(logPayloadJson)
                    request.setCompletionHandler(logSendCallback)
                    request.execute()
                }
                else {
                    logSendCallback(nil, AppLaunchAnalyticsError.noLogsToSend)
                }
            }
            catch let error as NSError {
                logSendCallback(nil, error)
            }
        })
    }
    
    
    // Same as the other send() method but for analytics
    internal static func sendAnalytics(completionHandler userCallback: BMSCompletionHandler? = nil) {
        
        guard !currentlySendingAnalyticsLogs else {
            
            Analytics.logger.info(message: "Ignoring Analytics.send() until the previous send request finishes.")
            
            return
        }
        
        currentlySendingAnalyticsLogs = true
        
        // Internal completion handler - wraps around the user supplied completion handler (if supplied)
        let analyticsSendCallback: BMSCompletionHandler = { (response: Response?, error: Error?) in
            
            currentlySendingAnalyticsLogs = false
            
            if error == nil && response?.statusCode == 202 {
                
                Analytics.logger.debug(message: "Analytics data successfully sent to the server.")
                
                AppLaunchLogger.delete(file: Constants.File.Analytics.outboundLogs)
            }
            else {
                
                var debugMessage = ""
                if let response = response {
                    if let statusCode = response.statusCode {
                        debugMessage += "Status code: \(statusCode). "
                    }
                    if let responseText = response.responseText {
                        debugMessage += "Response: \(responseText). "
                    }
                }
                if let error = error {
                    debugMessage += " Error: \(error)."
                }
                
                AppLaunchLogger.internalLogger.error(message: "Request to send analytics data has failed. To see more details, set Logger.sdkDebugLoggingEnabled to true, or send analytics with a completion handler to retrieve the response and error. Reason: \(debugMessage)")
                AppLaunchLogger.internalLogger.debug(message: debugMessage)
            }
            
            userCallback?(response, error)
        }

    
        // Use a serial queue to ensure that the same logs do not get sent more than once
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
            do {
                // Gather the logs and put them in a JSON object
                if let logsToSend: String = try AppLaunchLogger.getLogs(fromFile: Constants.File.Analytics.logs, overflowFileName: Constants.File.Analytics.overflowLogs, bufferFileName: Constants.File.Analytics.outboundLogs) {
                    var logPayloadJson = JSON()
                    logPayloadJson[Constants.outboundLogPayload].stringValue =  logsToSend
                    
                    let request = AppLaunchInvoker(url: AppLaunchAnalytics.url!, method: HttpMethod.POST, timeout: 60)
                    request.addHeader(APPLICATION_JSON, CONTENT_TYPE)
                    request.addHeader(AppLaunchAnalytics.clientSecret!, CLIENT_SECRET)
                    request.setJSONRequestBody(logPayloadJson)
                    request.setCompletionHandler(analyticsSendCallback)
                    request.execute()
                    
                }
                else {
                    analyticsSendCallback(nil, AppLaunchAnalyticsError.noLogsToSend)
                }
                

            }
            catch let error as NSError {
                analyticsSendCallback(nil, error)
            }
        })
    }
    
}



// MARK: -

/*
    Provides the internal implementation of the `Logger` class in the BMSAnalyticsAPI framework.
*/
internal class AppLaunchLogger: LoggerDelegate {
    
    
    // MARK: Properties (internal)
    
    // Internal instrumentation for troubleshooting issues in BMSCore
    internal static let internalLogger = Logger.logger(name: Constants.Package.logger)
    
    
    
    // MARK: Class constants (internal)
    
    // By default, the dateFormater will convert to the local time zone, but we want to send the date based on UTC
    // so that logs from all clients in all timezones are normalized to the same GMT timezone.
    internal static let dateFormatter: DateFormatter = AppLaunchLogger.generateDateFormatter()
    
    private static func generateDateFormatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss:SSS"
        
        return formatter
    }
    
    // Path to the log files on the client device
    internal static let logsDocumentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
    
    internal static let fileManager = FileManager.default

    
    
    // MARK: - Uncaught exceptions
    
    // True if the app crashed recently due to an uncaught exception.
    // This property will be set back to `false` if the logs are sent to the server.
    internal var isUncaughtExceptionDetected: Bool {
        
        get {
            return UserDefaults.standard.bool(forKey: Constants.uncaughtException)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.uncaughtException)
        }
    }
    
    // If the user set their own uncaught exception handler earlier, it gets stored here
    internal static let existingUncaughtExceptionHandler = NSGetUncaughtExceptionHandler()
    
    // This flag prevents infinite loops of uncaught exceptions
    internal static var exceptionHasBeenCalled = false
    internal static var signalHasBeenRaised = false
    internal static func startCapturingUncaughtExceptions() {
        
        NSSetUncaughtExceptionHandler { (uncaughtException: NSException) -> Void in
            if (!AppLaunchLogger.exceptionHasBeenCalled) {
                // Persist a flag so that when the app starts back up, we can see if an exception occurred in the last session
                AppLaunchLogger.exceptionHasBeenCalled = true
                
                AppLaunchLogger.log(exception: uncaughtException)
                AppLaunchAnalytics.logSessionEnd()
                
                AppLaunchLogger.existingUncaughtExceptionHandler?(uncaughtException)
            }
        }

        AppLaunchLogger.checkSignal()
    }
    
    internal static func checkSignal() {

        signal(SIGSEGV) { signal in
            AppLaunchLogger.logOtherThanNSException(signalValue:"SIGSEGV", signalReason:String(cString:strsignal(signal)) )
        }

        signal(SIGABRT) { signal in
            AppLaunchLogger.logOtherThanNSException(signalValue:"SIGABRT", signalReason:String(cString:strsignal(signal)) )
        }

        signal(SIGILL) { signal in
            AppLaunchLogger.logOtherThanNSException(signalValue:"SIGILL", signalReason:String(cString:strsignal(signal)) )
        }

        signal(SIGFPE) { signal in
            AppLaunchLogger.logOtherThanNSException(signalValue:"SIGFPE", signalReason:String(cString:strsignal(signal)) )
        }

        signal(SIGBUS) { signal in
            AppLaunchLogger.logOtherThanNSException(signalValue:"SIGBUS", signalReason:String(cString:strsignal(signal)) )
        }

        signal(SIGPIPE) { signal in
            AppLaunchLogger.logOtherThanNSException(signalValue:"SIGPIPE", signalReason:String(cString:strsignal(signal)) )
        }
    }

    internal static func logOtherThanNSException(signalValue:String, signalReason:String) {
        if !AppLaunchLogger.signalHasBeenRaised {
            AppLaunchLogger.signalHasBeenRaised = true
            AppLaunchLogger.exceptionHasBeenCalled = true
            AppLaunchLogger.log(trace: Thread.callStackSymbols, signalValue:signalValue, signalReason:signalReason )
            AppLaunchAnalytics.logSessionEnd()
            abort()
        }
    }

    internal static func log(trace crashTrace: [String], signalValue:String, signalReason:String) {

        let message = "App Crash: Crashed with signal \(signalValue) (\(signalReason))"

        let exceptionString = message
        let stacktrace = crashTrace

        var metadata: [String: Any] = [:]

        metadata[Constants.Metadata.Analytics.stacktrace] = stacktrace
        metadata[Constants.Metadata.Analytics.exceptionClass] = ""
        metadata[Constants.Metadata.Analytics.exceptionMessage] = message

        Logger.delegate?.logToFile(message: exceptionString, level: LogLevel.fatal, loggerName: Constants.Package.logger, calledFile: #file, calledFunction: #function, calledLineNumber: #line, additionalMetadata: metadata)
    }

    internal static func log(exception uncaughtException: NSException) {
        
        var metadata: [String: Any] = [:]
        var exceptionString = uncaughtException.name.rawValue // Placeholder in case there is no uncaughtException.reason
        
        metadata[Constants.Metadata.Analytics.stacktrace] = uncaughtException.callStackSymbols
        metadata[Constants.Metadata.Analytics.exceptionClass] = uncaughtException.name.rawValue
        if let reason = uncaughtException.reason {
            metadata[Constants.Metadata.Analytics.exceptionMessage] = reason
            exceptionString = reason
        }
        else {
            metadata[Constants.Metadata.Analytics.exceptionMessage] = ""
        }
        
        Logger.delegate?.logToFile(message: exceptionString, level: LogLevel.fatal, loggerName: Constants.Package.logger, calledFile: #file, calledFunction: #function, calledLineNumber: #line, additionalMetadata: metadata)
    }
    
    
    
    // MARK: - Writing logs to file
    
    // We use serial queues to prevent race conditions when multiple threads try to read/modify the same file
    
    internal static let loggerFileIOQueue = DispatchQueue(label: "com.ibm.mobilefirstplatform.clientsdk.swift.BMSCore.Logger.loggerFileIOQueue")
    
    internal static let analyticsFileIOQueue = DispatchQueue(label: "com.ibm.mobilefirstplatform.clientsdk.swift.BMSCore.Logger.analyticsFileIOQueue")
    


    // This is the master function that handles all of the logging, including level checking, printing to console, and writing to file
    // All other log functions below this one are helpers for this function
    internal func logToFile(message logMessage: String, level: LogLevel, loggerName: String, calledFile: String, calledFunction: String, calledLineNumber: Int, additionalMetadata: [String : Any]?) {
        
        let dispatchGroup = DispatchGroup()
        
        // Writing to file
        
        if level == LogLevel.analytics {
            guard Analytics.isEnabled else {
                return
            }
        }
        else {
            guard Logger.isLogStorageEnabled else {
                return
            }
        }
        
        // Get file names and the dispatch queue needed to access those files
        let (logFile, logOverflowFile, fileDispatchQueue) = AppLaunchLogger.getFiles(for: level)
        
        fileDispatchQueue.async(group: dispatchGroup, qos: DispatchQoS.default, flags: DispatchWorkItemFlags.noQoS, execute: {
            
            // Check if the log file is larger than the maxLogStoreSize. If so, move the log file to the "overflow" file, and start logging to a new log file. If an overflow file already exists, those logs get overwritten.
            if AppLaunchLogger.isLogFileFull(logFile) {
                do {
                    try AppLaunchLogger.moveLogs(fromFile: logFile, toOverflowFile: logOverflowFile)
                }
                catch let error {
                    let logFileName = AppLaunchLogger.extractFileName(fromPath: logFile)
                    print("Log file \(logFileName) is full but the old logs could not be removed. Try sending the logs. Error: \(error)")
                    return
                }
            }
            
            let timeStampString = AppLaunchLogger.dateFormatter.string(from: Date())
            var logAsJsonString = AppLaunchLogger.convertToJson(message: logMessage, level: level, loggerName: loggerName, timeStamp: timeStampString, additionalMetadata: additionalMetadata)
            
            guard logAsJsonString != nil else {
                let errorMessage = "Failed to write logs to file. This is likely because the analytics metadata could not be parsed."
                
                Logger.printLog(message: errorMessage, loggerName:loggerName, level: .error, calledFunction: #function, calledFile: #file, calledLineNumber: #line)
                
                
                return
            }
            
            logAsJsonString! += "," // Logs must be comma-separated
            
            AppLaunchLogger.write(toFile: logFile, logMessage: logAsJsonString!, loggerName: loggerName)
        })
        
        let _ = dispatchGroup.wait(timeout: .distantFuture)
    }
    
    
    // Get the full path to the log file and overflow file, and get the dispatch queue that they need to be operated on.
    internal static func getFiles(for level: LogLevel) -> (String, String, DispatchQueue) {
        
        var logFile: String = AppLaunchLogger.logsDocumentPath
        var logOverflowFile: String = AppLaunchLogger.logsDocumentPath
        var fileDispatchQueue: DispatchQueue
        
        if level == LogLevel.analytics {
            logFile += Constants.File.Analytics.logs
            logOverflowFile += Constants.File.Analytics.overflowLogs
            fileDispatchQueue = AppLaunchLogger.analyticsFileIOQueue
        }
        else {
            logFile += Constants.File.Logger.logs
            logOverflowFile += Constants.File.Logger.overflowLogs
            fileDispatchQueue = AppLaunchLogger.loggerFileIOQueue
        }
        
        return (logFile, logOverflowFile, fileDispatchQueue)
    }
    
    
    // Check if the log file size exceeds the limit set by the Logger.maxLogStoreSize property
    // Logs are actually distributed evenly between a "normal" log file and an "overflow" file, but we only care if the "normal" log file is full (half of the total maxLogStoreSize)
    internal static func isLogFileFull(_ logFile: String) -> Bool {
        
        if (AppLaunchLogger.fileManager.fileExists(atPath: logFile)) {
        
            do {   
                let attribute : NSDictionary? = try FileManager.default.attributesOfItem(atPath: logFile) as NSDictionary?
                if let currentLogFileSize = attribute?.fileSize() {
                    return currentLogFileSize > Logger.maxLogStoreSize / 2 // Divide by 2 since the total log storage gets shared between the log file and the overflow file
                }
            }
            catch let error {
                let logFile = AppLaunchLogger.extractFileName(fromPath: logFile)
                print("Cannot determine the size of file:\(logFile) due to error: \(error). In case the file size is greater than the specified max log storage size, logs will not be written to file.")
            }
        }
        
        return false
    }
    
    
    // Convert log message and metadata into JSON format. This is the actual string that gets written to the log files.
    internal static func convertToJson(message logMessage: String, level: LogLevel, loggerName: String, timeStamp: String, additionalMetadata: [String: Any]?) -> String? {
    
        var logMetadata: [String: Any] = [:]
        logMetadata[Constants.Metadata.Logger.timestamp] = timeStamp
        logMetadata[Constants.Metadata.Logger.level] = level.asString
        logMetadata[Constants.Metadata.Logger.package] = loggerName
        logMetadata[Constants.Metadata.Logger.message] = logMessage
    
        if additionalMetadata != nil {
            logMetadata[Constants.Metadata.Logger.metadata] = additionalMetadata! // Typically only available if the Logger.analytics method was called
        }
    
        let logData: Data
        do {
            logData = try JSONSerialization.data(withJSONObject: logMetadata, options: [])
        }
        catch {
            return nil
        }
        
        return String(data: logData, encoding: .utf8)
    }
    
    
    // When the log file is full, the old logs are moved to the overflow file to make room for new logs
    internal static func moveLogs(fromFile logFile: String, toOverflowFile overflowFile: String) throws {
        
        if AppLaunchLogger.fileManager.fileExists(atPath: overflowFile) && AppLaunchLogger.fileManager.isDeletableFile(atPath: overflowFile) {
            try AppLaunchLogger.fileManager.removeItem(atPath: overflowFile)
        }
        try AppLaunchLogger.fileManager.moveItem(atPath: logFile, toPath: overflowFile)
    }
    
    
    // Append log message to the end of the log file
    internal static func write(toFile file: String, logMessage: String, loggerName: String) {
            
        if !AppLaunchLogger.fileManager.fileExists(atPath: file) {
            AppLaunchLogger.fileManager.createFile(atPath: file, contents: nil, attributes: nil)
        }
        
        let fileHandle = FileHandle(forWritingAtPath: file)
        let data = logMessage.data(using: .utf8)
        
        if fileHandle != nil && data != nil {
            fileHandle!.seekToEndOfFile()
            fileHandle!.write(data!)
            fileHandle!.closeFile()
        }
        else {
            let errorMessage = "Cannot write to file: \(file)."

            Logger.printLog(message: errorMessage, loggerName: loggerName, level: LogLevel.error, calledFunction: #function, calledFile: #file, calledLineNumber: #line)
        }
        
    }
    
    
    // When logging messages to the user, make sure to only mention the log file name, not the full path since it may contain sensitive data unique to the device.
    internal static func extractFileName(fromPath filePath: String) -> String {
        
        var logFileName = Constants.File.unknown
        let fileUrl = URL(string: filePath)
        if let lastPathComponent = fileUrl?.lastPathComponent, !lastPathComponent.isEmpty {
            logFileName = lastPathComponent
        }
        return logFileName
    }
    
    
    
    // MARK: - Sending logs

    
    
    // If this is reached, the user most likely failed to initialize BMSClient or Analytics
    internal static func returnInitializationError(className uninitializedClass: String, missingValue: String, callback: BMSCompletionHandler) {
        
        AppLaunchLogger.internalLogger.error(message: "No value found for the \(uninitializedClass) \(missingValue) property. Make sure that \(uninitializedClass) is initialized before sending logs to the server.")
        
        var error: Error?
        switch uninitializedClass {
        case "Analytics":
            error = AppLaunchAnalyticsError.analyticsNotInitialized
        case "BMSClient":
            error = BMSCoreError.clientNotInitialized
        default:
            error = nil
        }
        
        callback(nil, error)
    }
    
    
    // Read the logs from file, move them to the "send" buffer file, and return the logs
    internal static func getLogs(fromFile fileName: String, overflowFileName: String, bufferFileName: String) throws -> String? {
        
        let logFile = AppLaunchLogger.logsDocumentPath + fileName // Original log file
        let overflowLogFile = AppLaunchLogger.logsDocumentPath + overflowFileName // Extra file in case original log file got full
        let bufferLogFile = AppLaunchLogger.logsDocumentPath + bufferFileName // Temporary file for sending logs
        
        // First check if the "*.log.send" buffer file already contains logs. This will be the case if the previous attempt to send logs failed.
        if AppLaunchLogger.fileManager.isReadableFile(atPath: bufferLogFile) {
            return try readLogs(fromFile: bufferLogFile)
        }
        else if AppLaunchLogger.fileManager.isReadableFile(atPath: logFile) {
            // Merge the logs from the normal log file and the overflow log file (if necessary)
            if AppLaunchLogger.fileManager.isReadableFile(atPath: overflowLogFile) {
                let fileContents = try String(contentsOfFile: overflowLogFile, encoding: .utf8)
                
                AppLaunchLogger.write(toFile: logFile, logMessage: fileContents, loggerName: AppLaunchLogger.internalLogger.name)
            }
            
            // Since the buffer log is empty, we move the log file to the buffer file in preparation of sending the logs. When new logs are recorded, a new log file gets created to replace it.
            try AppLaunchLogger.fileManager.moveItem(atPath: logFile, toPath: bufferLogFile)
            return try readLogs(fromFile: bufferLogFile)
        }
        else {
            AppLaunchLogger.internalLogger.debug(message: "No logs have been recorded since they were last sent to the server.")
            return nil
        }
    }
    
    
    // We should only be sending logs from a buffer file, which is a copy of the normal log file. This way, if the logs fail to get sent to the server, we can hold onto them until the send succeeds, while continuing to log to the normal log file.
    internal static func readLogs(fromFile bufferLogFile: String) throws -> String? {
        
        let analyticsOutboundLogs: String = AppLaunchLogger.logsDocumentPath + Constants.File.Analytics.outboundLogs
        let loggerOutboundLogs: String = AppLaunchLogger.logsDocumentPath + Constants.File.Logger.outboundLogs
        
        
        var fileContents: String?
        
        do {
            // Before sending the logs, we need to read them from the file. This is done in a serial dispatch queue to prevent conflicts if the log file is simulatenously being written to.
            switch bufferLogFile {
            case analyticsOutboundLogs:
                try dispatch_sync_throwable(AppLaunchLogger.analyticsFileIOQueue, block: { () -> () in
                    fileContents = try String(contentsOfFile: bufferLogFile, encoding: .utf8)
                })
            case loggerOutboundLogs:
                try dispatch_sync_throwable(AppLaunchLogger.loggerFileIOQueue, block: { () -> () in
                    fileContents = try String(contentsOfFile: bufferLogFile, encoding: .utf8)
                })
            default:
                AppLaunchLogger.internalLogger.error(message: "Cannot send data to server. Unrecognized file: \(bufferLogFile).")
            }
        }
        
        return fileContents
    }
    
    
    // For deleting files where only the file name is supplied, not the full path
    internal static func delete(file fileName: String) {
        
        let pathToFile = AppLaunchLogger.logsDocumentPath + fileName
        
        if AppLaunchLogger.fileManager.fileExists(atPath: pathToFile) && AppLaunchLogger.fileManager.isDeletableFile(atPath: pathToFile) {
            do {
                try AppLaunchLogger.fileManager.removeItem(atPath: pathToFile)
            }
            catch let error {
                AppLaunchLogger.internalLogger.error(message: "Failed to delete log file \(fileName) after sending. Error: \(error)")
            }
        }
    }

}

    

// MARK: - Helper

// Custom dispatch_sync that can incorporate throwable statements
internal func dispatch_sync_throwable(_ queue: DispatchQueue, block: () throws -> ()) throws {
    
    var error: Error?
    queue.sync(execute: {
        do {
            try block()
        }
        catch let caughtError {
            error = caughtError
        }
    })
    if error != nil {
        throw error!
    }
}



    
    
/**************************************************************************************************/
