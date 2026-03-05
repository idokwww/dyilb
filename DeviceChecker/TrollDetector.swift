import Foundation

struct TrollStatus {
    let status: String
    let isTrollStoreInstalled: Bool
    let details: [String: String]
}

class TrollDetector {
    private let kfdManager: KFDManager
    
    init(kfdManager: KFDManager) {
        self.kfdManager = kfdManager
    }
    
    func detectTrollStore() -> TrollStatus {
        var details: [String: String] = [:]
        var isTrollStoreInstalled = false
        
        if detectCoreTrustVulnerability(&details) {
            isTrollStoreInstalled = true
        }
        
        if detectTrollStoreFiles(&details) {
            isTrollStoreInstalled = true
        }
        
        if detectTrollPermissions(&details) {
            isTrollStoreInstalled = true
        }
        
        let status = isTrollStoreInstalled ? "已安装" : "未安装"
        
        return TrollStatus(status: status, isTrollStoreInstalled: isTrollStoreInstalled, details: details)
    }
    
    private func detectCoreTrustVulnerability(_ details: inout [String: String]) -> Bool {
        let coreTrustFiles = [
            "/var/containers/Bundle/Application/TrollStore.app",
            "/private/var/containers/Bundle/Application/TrollStore.app"
        ]
        
        for file in coreTrustFiles {
            if FileManager.default.fileExists(atPath: file) {
                details["trollStoreApp"] = "存在"
                return true
            }
        }
        
        if kfdManager.hasKernelAccess() {
            if checkCoreTrustPatch() {
                details["coreTrustPatched"] = "是"
                return true
            }
        }
        
        return false
    }
    
    private func detectTrollStoreFiles(_ details: inout [String: String]) -> Bool {
        let trollFiles = [
            "/var/mobile/Library/TrollStore",
            "/var/mobile/Library/TrollStore/apps",
            "/var/mobile/Library/TrollStore/trustcache.plist"
        ]
        
        var foundFiles: [String] = []
        for file in trollFiles {
            if FileManager.default.fileExists(atPath: file) {
                foundFiles.append(file)
            }
        }
        
        if !foundFiles.isEmpty {
            details["trollStoreFiles"] = foundFiles.joined(", ")
            return true
        }
        return false
    }
    
    private func detectTrollPermissions(_ details: inout [String: String]) -> Bool {
        let bundlePath = Bundle.main.bundlePath
        let isTrollSigned = checkTrollSigning(bundlePath: bundlePath)
        
        details["trollSigned"] = isTrollSigned ? "是" : "否"
        return isTrollSigned
    }
    
    private func checkCoreTrustPatch() -> Bool {
        if let coreTrustAddr = findCoreTrustInKernel() {
            let coreTrustData = kfdManager.readKernelMemory(addr: coreTrustAddr, size: 0x1000)
            if coreTrustData != nil {
                return checkCoreTrustForPatch(data: coreTrustData!)
            }
        }
        return false
    }
    
    private func checkTrollSigning(bundlePath: String) -> Bool {
        let entitlementsPath = bundlePath.appending("/Info.plist")
        if FileManager.default.fileExists(atPath: entitlementsPath) {
            if let plist = NSDictionary(contentsOfFile: entitlementsPath) {
                if let entitlements = plist["Entitlements"] as? NSDictionary {
                    if entitlements["com.apple.private.security.no-container"] != nil {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func findCoreTrustInKernel() -> UInt64? {
        return nil
    }
    
    private func checkCoreTrustForPatch(data: Data) -> Bool {
        return false
    }
}