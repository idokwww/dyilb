import SwiftUI

struct ContentView: View {
    @State private var isScanning = false
    @State private var scanResults: [String: Any] = [:]
    @State private var riskScore: Int = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("设备环境检测工具")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                if isScanning {
                    VStack(spacing: 10) {
                        ProgressView("正在检测...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.5)
                        Text("请稍候，正在进行内核级检测")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(40)
                } else if !scanResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            Section(header: Text("设备信息").font(.headline).bold()) {
                                InfoRow(label: "机型", value: scanResults["deviceModel"] as? String ?? "未知")
                                InfoRow(label: "iOS版本", value: scanResults["iosVersion"] as? String ?? "未知")
                                InfoRow(label: "内核版本", value: scanResults["kernelVersion"] as? String ?? "未知")
                                InfoRow(label: "UDID", value: scanResults["udid"] as? String ?? "未知")
                                InfoRow(label: "序列号", value: scanResults["serialNumber"] as? String ?? "未知")
                                InfoRow(label: "电池健康", value: scanResults["batteryHealth"] as? String ?? "未知")
                            }
                            
                            Section(header: Text("越狱状态").font(.headline).bold()) {
                                StatusRow(label: "越狱检测", status: scanResults["jailbreakStatus"] as? String ?? "未知", isRisk: scanResults["isJailbroken"] as? Bool ?? false)
                                if let jailbreakDetails = scanResults["jailbreakDetails"] as? [String: Any] {
                                    ForEach(jailbreakDetails.keys.sorted(), id: \.self) {
                                        key in
                                        InfoRow(label: key, value: jailbreakDetails[key] as? String ?? "未知")
                                    }
                                }
                            }
                            
                            Section(header: Text("巨魔状态").font(.headline).bold()) {
                                StatusRow(label: "巨魔检测", status: scanResults["trollStatus"] as? String ?? "未知", isRisk: false)
                                if let trollDetails = scanResults["trollDetails"] as? [String: Any] {
                                    ForEach(trollDetails.keys.sorted(), id: \.self) {
                                        key in
                                        InfoRow(label: key, value: trollDetails[key] as? String ?? "未知")
                                    }
                                }
                            }
                            
                            Section(header: Text("风险评估").font(.headline).bold()) {
                                HStack {
                                    Text("风险评分:")
                                    Spacer()
                                    Text("\(riskScore)/100")
                                        .font(.headline)
                                        .foregroundColor(riskScore > 70 ? .red : riskScore > 30 ? .orange : .green)
                                }
                                
                                GeometryReader {
                                    geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 10)
                                            .cornerRadius(5)
                                        Rectangle()
                                            .fill(riskScore > 70 ? Color.red : riskScore > 30 ? Color.orange : Color.green)
                                            .frame(width: geometry.size.width * CGFloat(riskScore) / 100, height: 10)
                                            .cornerRadius(5)
                                    }
                                }
                                .frame(height: 10)
                            }
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 30) {
                        Image(systemName: "shield.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                        
                        Text("点击下方按钮开始检测设备环境")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: runFullScan) {
                        Text("一键检测")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(isScanning)
                    
                    Button(action: exportReport) {
                        Text("导出报告")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .disabled(scanResults.isEmpty)
                }
                .padding()
            }
            .navigationTitle("设备检测")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
            }
        }
    }
    
    func runFullScan() {
        isScanning = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let kfdManager = KFDManager()
            let jailbreakDetector = JailbreakDetector(kfdManager: kfdManager)
            let trollDetector = TrollDetector(kfdManager: kfdManager)
            let deviceInfoReader = DeviceInfoReader(kfdManager: kfdManager)
            
            var results: [String: Any] = [:]
            
            results["deviceModel"] = deviceInfoReader.getDeviceModel()
            results["iosVersion"] = deviceInfoReader.getiOSVersion()
            results["kernelVersion"] = deviceInfoReader.getKernelVersion()
            results["udid"] = deviceInfoReader.getUDID()
            results["serialNumber"] = deviceInfoReader.getSerialNumber()
            results["batteryHealth"] = deviceInfoReader.getBatteryHealth()
            
            let jailbreakStatus = jailbreakDetector.detectJailbreak()
            results["jailbreakStatus"] = jailbreakStatus.status
            results["isJailbroken"] = jailbreakStatus.isJailbroken
            results["jailbreakDetails"] = jailbreakStatus.details
            
            let trollStatus = trollDetector.detectTrollStore()
            results["trollStatus"] = trollStatus.status
            results["trollDetails"] = trollStatus.details
            
            var score = 0
            if jailbreakStatus.isJailbroken {
                score += 80
            }
            if trollStatus.isTrollStoreInstalled {
                score += 20
            }
            
            DispatchQueue.main.async {
                scanResults = results
                riskScore = score
                isScanning = false
                alertMessage = "检测完成"
                showAlert = true
            }
        }
    }
    
    func exportReport() {
        let generator = ReportGenerator()
        let success = generator.exportReport(results: scanResults, riskScore: riskScore)
        
        if success {
            alertMessage = "报告已导出到文件应用"
        } else {
            alertMessage = "导出失败，请检查权限"
        }
        showAlert = true
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct StatusRow: View {
    let label: String
    let status: String
    let isRisk: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(status)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isRisk ? .red : .green)
        }
    }
}