import Foundation
import UIKit

class DeviceInfoReader {
    private let kfdManager: KFDManager
    
    init(kfdManager: KFDManager) {
        self.kfdManager = kfdManager
    }
    
    func getDeviceModel() -> String {
        if kfdManager.hasKernelAccess() {
            return getKernelDeviceModel()
        } else {
            return UIDevice.current.modelName
        }
    }
    
    func getiOSVersion() -> String {
        if kfdManager.hasKernelAccess() {
            return getKerneliOSVersion()
        } else {
            return UIDevice.current.systemVersion
        }
    }
    
    func getKernelVersion() -> String {
        if kfdManager.hasKernelAccess() {
            return getKernelVersionFromKernel()
        } else {
            return "未知"
        }
    }
    
    func getUDID() -> String {
        if kfdManager.hasKernelAccess() {
            return getKernelUDID()
        } else {
            return UIDevice.current.identifierForVendor?.uuidString ?? "未知"
        }
    }
    
    func getSerialNumber() -> String {
        if kfdManager.hasKernelAccess() {
            return getKernelSerialNumber()
        } else {
            return "未知"
        }
    }
    
    func getBatteryHealth() -> String {
        if let batteryLevel = UIDevice.current.batteryLevel as? Float {
            let percentage = Int(batteryLevel * 100)
            return "\(percentage)%"
        }
        return "未知"
    }
    
    private func getKernelDeviceModel() -> String {
        if let modelAddr = findDeviceModelInKernel() {
            let modelData = kfdManager.readKernelMemory(addr: modelAddr, size: 100)
            if let data = modelData, let model = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return model
            }
        }
        return UIDevice.current.modelName
    }
    
    private func getKerneliOSVersion() -> String {
        if let versionAddr = findiOSVersionInKernel() {
            let versionData = kfdManager.readKernelMemory(addr: versionAddr, size: 50)
            if let data = versionData, let version = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return version
            }
        }
        return UIDevice.current.systemVersion
    }
    
    private func getKernelVersionFromKernel() -> String {
        if let versionAddr = findKernelVersionInKernel() {
            let versionData = kfdManager.readKernelMemory(addr: versionAddr, size: 100)
            if let data = versionData, let version = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return version
            }
        }
        return "未知"
    }
    
    private func getKernelUDID() -> String {
        if let udidAddr = findUDIDInKernel() {
            let udidData = kfdManager.readKernelMemory(addr: udidAddr, size: 40)
            if let data = udidData, let udid = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return udid
            }
        }
        return UIDevice.current.identifierForVendor?.uuidString ?? "未知"
    }
    
    private func getKernelSerialNumber() -> String {
        if let serialAddr = findSerialNumberInKernel() {
            let serialData = kfdManager.readKernelMemory(addr: serialAddr, size: 50)
            if let data = serialData, let serial = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return serial
            }
        }
        return "未知"
    }
    
    private func findDeviceModelInKernel() -> UInt64? {
        return nil
    }
    
    private func findiOSVersionInKernel() -> UInt64? {
        return nil
    }
    
    private func findKernelVersionInKernel() -> UInt64? {
        return nil
    }
    
    private func findUDIDInKernel() -> UInt64? {
        return nil
    }
    
    private func findSerialNumberInKernel() -> UInt64? {
        return nil
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPhone1,1":  return "iPhone 2G"
        case "iPhone1,2":  return "iPhone 3G"
        case "iPhone2,1":  return "iPhone 3GS"
        case "iPhone3,1":  return "iPhone 4"
        case "iPhone3,2":  return "iPhone 4"
        case "iPhone3,3":  return "iPhone 4"
        case "iPhone4,1":  return "iPhone 4S"
        case "iPhone5,1":  return "iPhone 5"
        case "iPhone5,2":  return "iPhone 5"
        case "iPhone5,3":  return "iPhone 5c"
        case "iPhone5,4":  return "iPhone 5c"
        case "iPhone6,1":  return "iPhone 5s"
        case "iPhone6,2":  return "iPhone 5s"
        case "iPhone7,1":  return "iPhone 6 Plus"
        case "iPhone7,2":  return "iPhone 6"
        case "iPhone8,1":  return "iPhone 6s"
        case "iPhone8,2":  return "iPhone 6s Plus"
        case "iPhone8,4":  return "iPhone SE"
        case "iPhone9,1":  return "iPhone 7"
        case "iPhone9,2":  return "iPhone 7 Plus"
        case "iPhone9,3":  return "iPhone 7"
        case "iPhone9,4":  return "iPhone 7 Plus"
        case "iPhone10,1": return "iPhone 8"
        case "iPhone10,2": return "iPhone 8 Plus"
        case "iPhone10,3": return "iPhone X"
        case "iPhone10,4": return "iPhone 8"
        case "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,6": return "iPhone X"
        case "iPhone11,1": return "iPhone XR"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,3": return "iPhone XS Max"
        case "iPhone11,4": return "iPhone XS Max"
        case "iPhone11,6": return "iPhone XS Max"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,2": return "iPhone 11 Pro"
        case "iPhone12,3": return "iPhone 11 Pro Max"
        case "iPhone12,5": return "iPhone 12 Mini"
        case "iPhone12,8": return "iPhone SE (2nd generation)"
        case "iPhone13,1": return "iPhone 12"
        case "iPhone13,2": return "iPhone 12 Pro"
        case "iPhone13,3": return "iPhone 12 Pro Max"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,4": return "iPhone 13 Mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,6": return "iPhone SE (3rd generation)"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        default: return identifier
        }
    }
}