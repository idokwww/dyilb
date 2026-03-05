import Foundation

struct JailbreakStatus {
    let status: String
    let isJailbroken: Bool
    let details: [String: String]
}

class JailbreakDetector {
    private let kfdManager: KFDManager
    
    init(kfdManager: KFDManager) {
        self.kfdManager = kfdManager
    }
    
    func detectJailbreak() -> JailbreakStatus {
        var details: [String: String] = [:]
        var isJailbroken = false
        
        if kfdManager.hasKernelAccess() {
            isJailbroken = detectKernelLevelJailbreak(&details)
        } else {
            isJailbroken = detectUserLevelJailbreak(&details)
        }
        
        let status: String
        if isJailbroken {
            if details["jailbreakType"] == "full" {
                status = "完整越狱"
            } else {
                status = "无根越狱"
            }
        } else {
            status = "未越狱"
        }
        
        return JailbreakStatus(status: status, isJailbroken: isJailbroken, details: details)
    }
    
    private func detectKernelLevelJailbreak(_ details: inout [String: String]) -> Bool {
        var jailbroken = false
        
        if detectProcStructHooks(&details) {
            jailbroken = true
            details["jailbreakType"] = "full"
        }
        
        if detectSyscallHooks(&details) {
            jailbroken = true
            details["jailbreakType"] = "full"
        }
        
        if detectVFSWritable(&details) {
            jailbroken = true
            details["jailbreakType"] = "full"
        }
        
        if detectSandboxBypass(&details) {
            jailbroken = true
            details["jailbreakType"] = "rootless"
        }
        
        if detectJailbreakProcesses(&details) {
            jailbroken = true
        }
        
        return jailbroken
    }
    
    private func detectUserLevelJailbreak(_ details: inout [String: String]) -> Bool {
        var jailbroken = false
        
        if detectJailbreakFiles(&details) {
            jailbroken = true
        }
        
        if detectJailbreakPaths(&details) {
            jailbroken = true
        }
        
        if detectEnvironmentVariables(&details) {
            jailbroken = true
        }
        
        if detectCydiaURLScheme() {
            jailbroken = true
            details["cydiaScheme"] = "存在"
        }
        
        return jailbroken
    }
    
    private func detectProcStructHooks(_ details: inout [String: String]) -> Bool {
        guard let procStruct = kfdManager.getProcStruct(pid: getpid()) else {
            return false
        }
        
        let procData = kfdManager.readKernelMemory(addr: procStruct, size: 0x1000)
        if procData != nil {
            let isHooked = checkProcStructForHooks(data: procData!)
            details["procStructHooked"] = isHooked ? "是" : "否"
            return isHooked
        }
        return false
    }
    
    private func detectSyscallHooks(_ details: inout [String: String]) -> Bool {
        guard let syscallTable = kfdManager.getSyscallTable() else {
            return false
        }
        
        let tableData = kfdManager.readKernelMemory(addr: syscallTable, size: 0x1000)
        if tableData != nil {
            let isHooked = checkSyscallTableForHooks(data: tableData!)
            details["syscallHooked"] = isHooked ? "是" : "否"
            return isHooked
        }
        return false
    }
    
    private func detectVFSWritable(_ details: inout [String: String]) -> Bool {
        guard let mountTable = kfdManager.getVFSMountTable() else {
            return false
        }
        
        let mountData = kfdManager.readKernelMemory(addr: mountTable, size: 0x1000)
        if mountData != nil {
            let isWritable = checkVFSMountsForWritable(data: mountData!)
            details["systemPartitionWritable"] = isWritable ? "是" : "否"
            return isWritable
        }
        return false
    }
    
    private func detectSandboxBypass(_ details: inout [String: String]) -> Bool {
        guard let sandboxPolicy = kfdManager.getSandboxPolicy(pid: getpid()) else {
            return false
        }
        
        let policyData = kfdManager.readKernelMemory(addr: sandboxPolicy, size: 0x1000)
        if policyData != nil {
            let isBypassed = checkSandboxPolicyForBypass(data: policyData!)
            details["sandboxBypassed"] = isBypassed ? "是" : "否"
            return isBypassed
        }
        return false
    }
    
    private func detectJailbreakProcesses(_ details: inout [String: String]) -> Bool {
        let jailbreakProcesses = ["Cydia", "Sileo", "Zebra", "Installer", "Tweak Injector"]
        var foundProcesses: [String] = []
        
        for process in jailbreakProcesses {
            if isProcessRunning(process) {
                foundProcesses.append(process)
            }
        }
        
        if !foundProcesses.isEmpty {
            details["jailbreakProcesses"] = foundProcesses.joined(", ")
            return true
        }
        return false
    }
    
    private func detectJailbreakFiles(_ details: inout [String: String]) -> Bool {
        let jailbreakFiles = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Applications/Installer.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/usr/lib/substrate",
            "/usr/bin/cycript",
            "/usr/bin/ssh",
            "/etc/ssh/sshd_config",
            "/usr/sbin/sshd"
        ]
        
        var foundFiles: [String] = []
        for file in jailbreakFiles {
            if FileManager.default.fileExists(atPath: file) {
                foundFiles.append(file)
            }
        }
        
        if !foundFiles.isEmpty {
            details["jailbreakFiles"] = foundFiles.joined(", ")
            return true
        }
        return false
    }
    
    private func detectJailbreakPaths(_ details: inout [String: String]) -> Bool {
        let jailbreakPaths = ["/var/lib/cydia", "/var/cache/apt", "/var/lib/apt", "/private/var/lib/cydia"]
        
        var foundPaths: [String] = []
        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                foundPaths.append(path)
            }
        }
        
        if !foundPaths.isEmpty {
            details["jailbreakPaths"] = foundPaths.joined(", ")
            return true
        }
        return false
    }
    
    private func detectEnvironmentVariables(_ details: inout [String: String]) -> Bool {
        let envVars = ["Cydia", "CYDIA", "SILEO", "ZEBRA"]
        
        var foundVars: [String] = []
        for env in envVars {
            if let value = kfdManager.getEnvironmentVariable(name: env) {
                foundVars.append("\(env)=\(value)")
            }
        }
        
        if !foundVars.isEmpty {
            details["jailbreakEnvVars"] = foundVars.joined(", ")
            return true
        }
        return false
    }
    
    private func detectCydiaURLScheme() -> Bool {
        let url = URL(string: "cydia://")!
        return UIApplication.shared.canOpenURL(url)
    }
    
    private func isProcessRunning(_ processName: String) -> Bool {
        let task = Process()
        let pipe = Pipe()
        
        task.launchPath = "/bin/ps"
        task.arguments = ["-e"]
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return output.contains(processName)
        } catch {
            return false
        }
    }
    
    private func checkProcStructForHooks(data: Data) -> Bool {
        return false
    }
    
    private func checkSyscallTableForHooks(data: Data) -> Bool {
        return false
    }
    
    private func checkVFSMountsForWritable(data: Data) -> Bool {
        return false
    }
    
    private func checkSandboxPolicyForBypass(data: Data) -> Bool {
        return false
    }
}