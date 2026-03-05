import Foundation
import UIKit

class KFDManager {
    private var isInitialized = false
    private var hasKernelAccess = false
    
    init() {
        initializeKFD()
    }
    
    func initializeKFD() {
        let osVersion = UIDevice.current.systemVersion
        let majorVersion = Int(osVersion.components(separatedBy: ".")[0]) ?? 0
        
        if majorVersion >= 14 && majorVersion <= 16 {
            isInitialized = kfd_initialize()
            if isInitialized {
                hasKernelAccess = kfd_get_kernel_access()
            }
        }
    }
    
    func hasKernelAccess() -> Bool {
        return hasKernelAccess
    }
    
    func readKernelMemory(addr: UInt64, size: Int) -> Data? {
        if !hasKernelAccess {
            return nil
        }
        
        var buffer = [UInt8](repeating: 0, count: size)
        let success = kfd_read_kernel_memory(addr, &buffer, size)
        if success {
            return Data(buffer)
        }
        return nil
    }
    
    func writeKernelMemory(addr: UInt64, data: Data) -> Bool {
        if !hasKernelAccess {
            return false
        }
        
        return data.withUnsafeBytes { buffer in
            if let baseAddress = buffer.baseAddress {
                let uint8Buffer = baseAddress.assumingMemoryBound(to: UInt8.self)
                return kfd_write_kernel_memory(addr, uint8Buffer, data.count)
            }
            return false
        }
    }
    
    func getProcStruct(pid: Int) -> UInt64? {
        if !hasKernelAccess {
            return nil
        }
        return kfd_get_proc_struct(pid)
    }
    
    func getSyscallTable() -> UInt64? {
        if !hasKernelAccess {
            return nil
        }
        return kfd_get_syscall_table()
    }
    
    func getVFSMountTable() -> UInt64? {
        if !hasKernelAccess {
            return nil
        }
        return kfd_get_vfs_mount_table()
    }
    
    func getSandboxPolicy(pid: Int) -> UInt64? {
        if !hasKernelAccess {
            return nil
        }
        return kfd_get_sandbox_policy(pid)
    }
    
    func getEnvironmentVariable(name: String) -> String? {
        if hasKernelAccess {
            if let cName = name.cString(using: .utf8) {
                if let result = kfd_get_environment_variable(cName) {
                    return String(cString: result)
                }
            }
        } else {
            if let cName = name.cString(using: .utf8) {
                if let result = getenv(cName) {
                    return String(cString: result)
                }
            }
        }
        return nil
    }
}

// C函数声明
func kfd_initialize() -> Bool
func kfd_get_kernel_access() -> Bool
func kfd_read_kernel_memory(_ addr: UInt64, _ buffer: UnsafeMutablePointer<UInt8>, _ size: Int) -> Bool
func kfd_write_kernel_memory(_ addr: UInt64, _ buffer: UnsafePointer<UInt8>, _ size: Int) -> Bool
func kfd_get_proc_struct(_ pid: Int) -> UInt64
func kfd_get_syscall_table() -> UInt64
func kfd_get_vfs_mount_table() -> UInt64
func kfd_get_sandbox_policy(_ pid: Int) -> UInt64
func kfd_get_environment_variable(_ name: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?