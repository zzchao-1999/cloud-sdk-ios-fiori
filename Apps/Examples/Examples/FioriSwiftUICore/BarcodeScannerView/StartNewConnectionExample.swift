import SwiftUI
import FioriSwiftUICore

struct StartNewConnectionExample: View {
    @StateObject private var scannerManager = BarcodeScannerManager.shared
    @State private var selectedScannerType: ScannerType?
    @State private var qrCodeImage: Image?
    
    var body: some View {
        VStack(spacing: 20) {
            // Scanner Selection Buttons
            HStack(spacing: 20) {
                Button(action: {
                    selectScanner(.proGlove)
                }) {
                    Text("ProGlove")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedScannerType == .proGlove ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedScannerType == .proGlove ? .white : .primary)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    selectScanner(.ipcMobile)
                }) {
                    Text("IPCMobile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedScannerType == .ipcMobile ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedScannerType == .ipcMobile ? .white : .primary)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            // Scanner Status
            HStack(spacing: 0) {
                Text("Status: ")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(scannerManager.status.description)
                    .font(.subheadline)
                    .foregroundColor(scannerManager.status == .ready ? .green : .blue)
            }
            
            // QR Code Display
            if let qrImage = self.qrCodeImage, selectedScannerType != nil, scannerManager.status != .ready {
                qrImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .border(Color.gray, width: 2)
                    .padding()
                Text("QR Code for \(selectedScannerType!.description)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
//            // Scanned Barcode Display
//            if let barcode = scannedBarcode {
//                Text("Scanned Barcode: \(barcode)")
//                    .font(.subheadline)
//                    .padding()
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
//            }
            
//            // Control Buttons
//            if selectedScannerType != nil {
//                HStack(spacing: 20) {
//                    Button("Start Monitoring") {
//                        scannerManager.startMonitoring()
//                    }
//                    .disabled(scannerManager.status == .scanning || scannerManager.status == .ready)
//                    
//                    Button("Stop Monitoring") {
//                        scannerManager.stopMonitoring()
//                    }
//                    .disabled(scannerManager.status != .scanning && scannerManager.status != .ready)
//                    
//                    Button("Reset") {
//                        scannerManager.resetActiveScanner()
//                        selectedScannerType = nil
//                        scannedBarcode = nil
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//            }
            if selectedScannerType != nil {
                HStack(alignment: .center) {
                    Button("Reset") {
                        scannerManager.resetActiveScanner()
                        selectedScannerType = nil
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Scanner Connection")
        .onAppear {
            // Set up scanner manager callbacks
//            scannerManager.onBarcodeScanned = { barcode in
//                scannedBarcode = barcode
//            }
            scannerManager.onStatusChanged = { status in
                if status == .error("Failed to generate QR code for pairing") {
                    selectedScannerType = nil
                    self.qrCodeImage = nil
                }
            }
        }
    }
    
    private func selectScanner(_ type: ScannerType) {
        selectedScannerType = type
        scannerManager.setActiveScanner(type)
        if let qrImage = scannerManager.getPairingQRCode() {
            self.qrCodeImage = qrImage
        } else {
            selectedScannerType = nil
            self.qrCodeImage = nil
        }
    }
}

//struct StartNewConnectionExample: View {
//    @StateObject private var scannerManager = BarcodeScannerManager.shared
//    @State private var proGloveQRCodeImage: Image?
//    @State private var ipcMobileQRCodeImage: Image?
//    
//    var body: some View {
////        if scannerManager.status == .ready && scannerManager.activeScannerType == .proGlove {
////            HStack(spacing: 20) {
////                Text("ProGlove Scanner Status:")
////                Text("Connected")
////                    .foregroundStyle(Color.green)
////                    .onAppear {
////                        scannerManager.updateScannerDisplay(message: "Ready for Scanning")
////                    }
////            }
////        } else {
////            VStack(spacing: 20) {
////                Text("Scan Pairing ProGlove Barcode Scanner")
////                    .font(.subheadline)
////                if let qrImage = proGloveQRCodeImage {
////                    qrImage
////                        .resizable()
////                        .scaledToFit()
////                        .frame(width: 200, height: 200)
////                } else {
////                    Text("Generating QR code...")
////                        .onAppear {
////                            scannerManager.setActiveScanner(.proGlove)
////                            scannerManager.startMonitoring()
////                        }
////                        .onChange(of: scannerManager.status) {newStatus in
////                            if newStatus == .poweredOn {
////                                generateProGloveQRCode()
////                            }
////                        }
////                }
////            }
////        }
//        if scannerManager.status == .ready && scannerManager.activeScannerType == .ipcMobile {
//            HStack(spacing: 20) {
//                Text("IPCMobile Scanner Status:")
//                Text("Connected")
//                    .foregroundStyle(Color.green)
//                    .onAppear {
//                        scannerManager.updateScannerDisplay(message: "HaloRing is ready for scanning")
//                    }
//            }
//        } else {
//            VStack(spacing: 20) {
//                Text("Scan Pairing IPCMobile Barcode Scanner")
//                    .font(.subheadline)
//                if let qrImage = ipcMobileQRCodeImage {
//                    qrImage
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 200, height: 200)
//                } else {
//                    Text("Generating QR code...")
//                        .onAppear {
//                            scannerManager.setActiveScanner(.ipcMobile)
//                            scannerManager.startMonitoring()
//                        }
//                        .onChange(of: scannerManager.status) {newStatus in
//                            if newStatus == .poweredOn {
//                                generateIPCQRCode()
//                            }
//                        }
//                }
//            }
//        }
//    }
//    
////    private func generateProGloveQRCode() {
////        Task { @MainActor in
////            scannerManager.setActiveScanner(.proGlove)
////            if let image = scannerManager.getPairingQRCode() {
////                self.proGloveQRCodeImage = image
////                print("QR code generated - isScannerReady: \(self.scannerManager.status == .ready), QR code exists")
////            } else {
////                print("Failed to generate QR code ")
////            }
////        }
////    }
//    
//    private func generateIPCQRCode() {
//        Task { @MainActor in
//            scannerManager.setActiveScanner(.ipcMobile)
//            if let image = scannerManager.getPairingQRCode() {
//                self.ipcMobileQRCodeImage = image
//                print("QR code generated - isScannerReady: \(self.scannerManager.status == .ready), QR code exists")
//            } else {
//                print("Failed to generate QR code ")
//            }
//        }
//    }
//}
