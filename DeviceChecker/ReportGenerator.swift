import Foundation
import UIKit

class ReportGenerator {
    func exportReport(results: [String: Any], riskScore: Int) -> Bool {
        let reportContent = generateReportContent(results: results, riskScore: riskScore)
        return saveReport(content: reportContent)
    }
    
    private func generateReportContent(results: [String: Any], riskScore: Int) -> String {
        var content = "# 设备环境检测报告\n\n"
        content += "## 检测时间\n"
        content += "\(Date().description)\n\n"
        
        content += "## 设备信息\n"
        content += "- 机型: \(results["deviceModel"] as? String ?? "未知")\n"
        content += "- iOS版本: \(results["iosVersion"] as? String ?? "未知")\n"
        content += "- 内核版本: \(results["kernelVersion"] as? String ?? "未知")\n"
        content += "- UIDID: \(results["udid"] as? String ?? "未知")\n"
        content += "- 序列号: \(results["serialNumber"] as? String ?? "未知")\n"
        content += "- 电池健康: \(results["batteryHealth"] as? String ?? "未知")\n\n"
        
        content += "## 越狱状态\n"
        content += "- 状态: \(results["jailbreakStatus"] as? String ?? "未知")\n"
        if let jailbreakDetails = results["jailbreakDetails"] as? [String: String] {
            for (key, value) in jailbreakDetails {
                content += "- \(key): \(value)\n"
            }
        }
        content += "\n"
        
        content += "## 巨魔状态\n"
        content += "- 状态: \(results["trollStatus"] as? String ?? "未知")\n"
        if let trollDetails = results["trollDetails"] as? [String: String] {
            for (key, value) in trollDetails {
                content += "- \(key): \(value)\n"
            }
        }
        content += "\n"
        
        content += "## 风险评估\n"
        content += "- 风险评分: \(riskScore)/100\n"
        content += "- 风险等级: \(getRiskLevel(score: riskScore))\n\n"
        
        content += "## 检测方法\n"
        content += "- 内核级检测: \(KFDManager().hasKernelAccess() ? "已使用" : "未使用")\n"
        content += "- 用户态检测: \(KFDManager().hasKernelAccess() ? "备用" : "已使用")\n"
        
        return content
    }
    
    private func getRiskLevel(score: Int) -> String {
        switch score {
        case 0: return "安全"
        case 1...30: return "低风险"
        case 31...70: return "中风险"
        case 71...100: return "高风险"
        default: return "未知"
        }
    }
    
    private func saveReport(content: String) -> Bool {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let fileName = "DeviceCheckReport_\(Date().timeIntervalSince1970).txt"
        let fileURL = directory.appendingPathComponent(fileName)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
            return true
        } catch {
            return false
        }
    }
}