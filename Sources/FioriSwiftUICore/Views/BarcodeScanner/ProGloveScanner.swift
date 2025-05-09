import SwiftUI
#if canImport(ConnectSDK)
import ConnectSDK

@MainActor
public final class ProGloveScanner: NSObject, BarcodeScanner, PGCentralManagerDelegate, PGPeripheralDelegate {
    public let type: ScannerType = .proGlove
    public weak var delegate: BarcodeScannerDelegate?
    public private(set) var currentStatus: ScannerStatus = .poweredOff
    
    private var central: PGCentralManager?
    private var displayedScanner: PGPeripheral?
    private var sdkState: PGManagerState = .unknown
    private var isScannerConnected: Bool = false
    private var lastError: String?

    public override init() {
        super.init()
        central = PGCentralManager(delegate: self, enableRestoration: false)
        sdkState = central?.state ?? .unknown
        updateInternalStatus()
    }
    
//    public var currentStatus: ScannerStatus {
//        if let error = lastError {
//            return .error(error)
//        }
//        switch sdkState {
//        case .unsupported:
//            return .error("Bluetooth LE not supported")
//        case .unauthorized:
//            return .error("Bluetooth permission not granted")
//        case .poweredOff:
//            return .poweredOff
//        case .poweredOn:
//            if isScannerConnected {
//                return .ready
//            } else if displayedScanner != nil {
//                return .initializing
//            } else {
//                return .poweredOn
//            }
//        case .resetting:
//            return .initializing
//        case .unknown:
//            fallthrough
//        @unknown default:
//            return .poweredOff
//        }
//    }
//
//    public override init() {
//        super.init()
//        central = PGCentralManager(delegate: self, enableRestoration: false)
//        sdkState = central?.state ?? .unknown
//        print("ProGloveScanner initialized. Initial SDK state: \(sdkState)")
//    }

    public func startMonitoring() {
        guard let central = central else {
            currentStatus = .error("PGCentralManager not initialized.")
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
            return
        }
        sdkState = central.state
        updateInternalStatus()
        delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
        print("ProGloveScanner: Start Monitoring. SDK State: \(sdkState)")
    }

    public func stopMonitoring() {
        reset()
        print("ProGloveScanner: Stop Monitoring called.")
    }

    public func getPairingQRCode() -> Image? {
        guard let central = central, sdkState == .poweredOn else {
            currentStatus = .error("Cannot pair: Bluetooth not ready")
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
            return nil
        }
        let uiImage = central.initiateScannerConnection(withImageSize: CGSize(width: 200, height: 200))
        return Image(uiImage: uiImage)
    }

    public func updateDisplay(message: String) {
        guard let central = central, let scanner = displayedScanner, isScannerConnected else {
            print("ProGloveScanner: Cannot update display - No scanner connected.")
            return
        }
        print("ProGloveScanner: Updating display with message: \(message)")
        let screenData = PGScreenData(
            templateId: "PG1A",
            templateFields: [PGTemplateField(fieldId: 1, header: "", content: message)],
            refreshType: .partialRefresh,
            duration: 10000
        )
        let command = PGCommand(screenDataRequest: screenData)
        central.displayManager?.setScreen(command, completionHandler: { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("ProGloveScanner: Failed to set screen: \(error)")
                self.currentStatus = .error("Display update failed: \(error.localizedDescription)")
                self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
            }
        })
    }

    public func reset() {
        print("ProGloveScanner: Reset requested.")
        if let scanner = displayedScanner {
            print("ProGloveScanner: Disconnecting scanner \(scanner.identifier).")
            central?.cancelScannerConnection(scanner)
        }
        displayedScanner = nil
        isScannerConnected = false
        lastError = nil
        sdkState = central?.state ?? .unknown
        updateInternalStatus()
        delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
    }

    public func isAvailable() -> Bool {
        sdkState == .poweredOn && isScannerConnected && currentStatus == .ready
//        print("ProGloveScanner: Connected: \(isScannerConnected), Status: \(currentStatus)")
    }

//    private func notifyStatusUpdate() {
//        let status = currentStatus
//        print("ProGloveScanner: Notifying delegate of status update: \(status)")
//        delegate?.scannerDidUpdateStatus(status, sender: self)
//    }

    public func managerDidUpdateState(_ manager: PGManager) {
        print("ProGloveScanner: SDK State Updated: \(manager.state)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.sdkState = manager.state
            if self.sdkState != .poweredOn {
                self.isScannerConnected = false
                self.displayedScanner = nil
                self.lastError = nil
            }
            self.updateInternalStatus()
            self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
        }
    }

    public func centralManager(_ centralManager: PGCentralManager, scannerDidBecomeReady scanner: PGPeripheral) {
        print("ProGloveScanner: Scanner Ready: \(scanner.identifier)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.displayedScanner = scanner
            scanner.delegate = self
            self.isScannerConnected = true
            self.lastError = nil
            self.updateInternalStatus()
            self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
        }
    }

    public func centralManager(_ centralManager: PGCentralManager, didFailToConnectToScanner scanner: PGPeripheral, error: Error?) {
        print("ProGloveScanner: Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.displayedScanner = nil
            self.isScannerConnected = false
            self.lastError = "Connection failed: \(error?.localizedDescription ?? "Unknown")"
            self.updateInternalStatus()
            self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
        }
    }

    public func centralManager(_ centralManager: PGCentralManager, didDisconnectFromScanner scanner: PGPeripheral, error: Error?) {
        print("ProGloveScanner: Disconnected: \(error?.localizedDescription ?? "Graceful disconnect")")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if scanner == self.displayedScanner {
                self.displayedScanner = nil
                self.isScannerConnected = false
                scanner.delegate = nil
                self.lastError = error?.localizedDescription
                self.updateInternalStatus()
                self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
            }
        }
    }

    public func peripheral(_ peripheral: PGPeripheral, didScanBarcodeWith data: PGScannedBarcodeResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let barcode = "\(data.barcodeContent)\(data.barcodeSymbology.map { " (\($0))" } ?? "")"
            self.delegate?.barcodeScannerDidReceiveBarcode(barcode, from: self)
            print("ProGloveScanner: Barcode received: \(barcode)")
        }
    }

    public func centralManager(_ centralManager: PGCentralManager, didStartSearchingForIndicator indicator: String?) {
        print("ProGloveScanner: Started searching for indicator: \(indicator ?? "nil")")
    }

    public func centralManager(_ centralManager: PGCentralManager, connectingToScanner scanner: PGPeripheral) {
        print("ProGloveScanner: Connecting to scanner \(scanner.identifier)...")
    }

    public func centralManager(_ centralManager: PGCentralManager, scannerDidConnect scanner: PGPeripheral) {
        print("ProGloveScanner: Scanner \(scanner.identifier) PHYSICALLY connected, waiting to become ready...")
    }

    public func centralManager(_ centralManager: PGCentralManager, didFailToInitiateConnection error: Error?) {
        print("ProGloveScanner: Failed to initiate connection: \(error?.localizedDescription ?? "Unknown error")")
//        lastError = "Pairing initiation failed: \(error?.localizedDescription ?? "Unknown error")"
//        notifyStatusUpdate()
    }

    public func centralManager(_ centralManager: PGCentralManager, didLostConnectionAndReconnectingToScanner scanner: PGPeripheral) {
        print("ProGloveScanner: Lost connection, reconnecting to \(scanner.identifier)...")
//        if scanner == displayedScanner {
//            isScannerConnected = false
//            lastError = "Connection lost, reconnecting..."
//            notifyStatusUpdate()
//        }
    }
    
    private func updateInternalStatus() {
        if let error = lastError {
            currentStatus = .error(error)
        } else {
            switch sdkState {
            case .unsupported:
                currentStatus = .error("Bluetooth LE not supported")
            case .unauthorized:
                currentStatus = .error("Bluetooth permission not granted")
            case .poweredOff:
                currentStatus = .poweredOff
            case .poweredOn:
                currentStatus = isScannerConnected ? .ready : .poweredOn
            case .resetting:
                currentStatus = .initializing
            case .unknown:
                currentStatus = .poweredOff
            @unknown default:
                currentStatus = .poweredOff
            }
        }
    }
}

#else
public class ProGloveScanner: NSObject, BarcodeScanner {
    public let type: ScannerType = .proGlove
    public weak var delegate: BarcodeScannerDelegate?
    public var currentStatus: ScannerStatus = .error("ProGlove SDK not available")

    public func startMonitoring() { notifyStatusUpdate() }
    public func stopMonitoring() {}
    public func initiatePairing() -> Image? { notifyStatusUpdate(); return nil }
    public func updateDisplay(message: String) { print("ProGlove SDK not available") }
    public func reset() { notifyStatusUpdate() }
    public func isAvailable() -> Bool {
        print("ProGloveScanner: Not available - SDK not imported")
        return false
    }

    private func notifyStatusUpdate() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.scannerDidUpdateStatus(self.currentStatus, sender: self)
        }
    }
}
#endif
