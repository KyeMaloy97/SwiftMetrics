import agentcore
import Foundation

public class SwiftMetrics {

    let loaderApi: loaderCoreFunctions
    let SWIFTMETRICS_VERSION = "99.99.99.29991231"
    var running = 1

    public init() {
       
        self.loaderApi = loader_entrypoint().pointee
        self.loadProperties()
        loaderApi.setLogLevels()
        loaderApi.setProperty("agentcore.version", loaderApi.getAgentVersion())
        loaderApi.setProperty("swiftmetrics.version", SWIFTMETRICS_VERSION)
        loaderApi.logMessage(info, "Swift Application Metrics")
    }

    private func loadProperties() {
       ///look for healthcenter.properties in current directory
       let fm = FileManager.default()
       var propertiesPath = ""
       var dirContents = try fm.contentsOfDirectory(atPath: fm.currentDirectoryPath)
       for dir in dirContents {
          if dir.contains("healthcenter.properties") {
             propertiesPath = "\(fm.currentDirectoryPath)/\(dir)"
          }
       }
       if propertiesPath.isEmpty {
          ///need to drill down into the omr-agentcore directory from where we are
          if fm.currentDirectoryPath.contains("omr-agentcore") == false {
             ///then we're in the wrong directory - go look for agentcore in the Packages directory
             _ = fm.changeCurrentDirectoryPath("Packages")
             let dirContents = try fm.contentsOfDirectory(atPath: fm.currentDirectoryPath)
             for dir in dirContents {
                if dir.contains("omr-agentcore") {
                   ///that's where we want to be!
                   _ = fm.changeCurrentDirectoryPath
                }
             }
          }
          propertiesPath = "\(fm.currentDirectoryPath)/properties/healthcenter.properties"
       }
    
       _ = loaderApi.loadPropertiesFile(propertiesPath) 
    }

    public func spath(path: String) {
        loaderApi.setProperty("com.ibm.diagnostics.healthcenter.plugin.path", path)
    }

    public func stop() {
        if (running == 0) {
            running = 1
            loaderApi.stop()
            loaderApi.shutdown()
        }
    }
  
    public func start() {
        if (running == 1) {
            running = 0
            _ = loaderApi.initialize()
            loaderApi.setProperty("com.ibm.diagnostics.healthcenter.mqtt", "on")
            loaderApi.start()
        }
    }

}