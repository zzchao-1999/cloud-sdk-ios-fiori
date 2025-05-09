import SwiftUI
import VisionKit
import AVFoundation

@MainActor
public final class VisionKitScanner: NSObject, BarcodeScanner, DataScannerViewControllerDelegate {
    public let type: ScannerType = .visionKit
    public weak var delegate: (any BarcodeScannerDelegate)?
    public private(set) var currentStatus: ScannerStatus = .poweredOff

    private var visionScannerVC: DataScannerViewController?
    private var isScanning: Bool = false
    private var isSupported: Bool { DataScannerViewController.isSupported }
    private var recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
    private var recognizesMultipleItems: Bool
    
    public init(
        recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>? = nil,
        recognizesMultipleItems: Bool? = nil
    ) {
        self.recognizedDataTypes = recognizedDataTypes ?? Set([.barcode()])
        self.recognizesMultipleItems = recognizesMultipleItems ?? false
        super.init()
        updateInternalStatus()
    }

    public func startMonitoring() {
        checkPermissions { [weak self] granted in
            guard let self = self else { return }
            if granted && self.isSupported {
                self.initializeScannerVCIfNeeded()
                self.currentStatus = .ready
            } else {
                self.currentStatus = .error(granted ? "Camera not supported" : "Camera permission denied")
            }
            self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
        }
    }

    public func stopMonitoring() {
        stopScanning()
        visionScannerVC?.removeFromParent()
        visionScannerVC = nil
        updateInternalStatus()
        delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
    }

    public func reset() {
        stopScanning()
        visionScannerVC = nil
        updateInternalStatus()
        delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
    }

    public func triggerScan() {
        checkPermissions { [weak self] granted in
            guard let self = self else { return }
                if granted && self.isSupported {
                    self.initializeScannerVCIfNeeded()
                    self.startScanning()
                } else {
                    self.currentStatus = .error(granted ? "Camera not supported" : "Camera permission denied")
                    self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
                }
        }
    }

    public func getScannerViewController() -> DataScannerViewController? {
        initializeScannerVCIfNeeded()
        return visionScannerVC
    }
    
    public func isAvailable() -> Bool {
        var isAvailable = false
        checkPermissions { granted in
            isAvailable = granted && self.isSupported && self.currentStatus == .ready
        }
        return isAvailable
    }

    public func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        var receivedData = false
        for item in addedItems {
            switch item {
            case .barcode(let barcode):
                if let payload = barcode.payloadStringValue {
                    delegate?.barcodeScannerDidReceiveBarcode(payload, from: self)
                    receivedData = true
                }
            case .text(let text):
                delegate?.barcodeScannerDidReceiveBarcode(text.transcript, from: self)
                receivedData = true
            @unknown default:
                print("Unknown item type detected")
            }
        }
        if receivedData && !recognizesMultipleItems {
            stopScanning()
        }
    }

    public func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        if !updatedItems.isEmpty {
            print("VisionKitScanner: Items updated - \(updatedItems.count) items")
        }
    }
    
    public func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        print("VisionKitScanner: Items removed - \(removedItems.count) items")
    }
    
    public func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: Error) {
        isScanning = false
        currentStatus = .error("Scanner unavailable: \(error.localizedDescription)")
        visionScannerVC = nil
        delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
    }
    
    public func dataScannerWasReplaced(_ dataScanner: DataScannerViewController) {
        let wasScanningPreviously = self.isScanning
        if wasScanningPreviously {
            stopScanning()
        }
        visionScannerVC = dataScanner
        visionScannerVC?.delegate = self
        if wasScanningPreviously {
            if self.currentStatus == .ready {
                startScanning()
            }
        } else {
            updateInternalStatus()
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
        }
    }

    private func initializeScannerVCIfNeeded() {
        guard visionScannerVC == nil else { return }
        guard isSupported else {
            currentStatus = .error("Camera not supported.")
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
            return
        }
        guard hasPermissions() else {
            currentStatus = .error("Camera permission denied.")
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
            return
        }

        let vc = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            // whether overlay an interface on the live video
            isHighFrameRateTrackingEnabled: true,
            // whether remove text that appears in the live video
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        vc.delegate = self
        visionScannerVC = vc
        updateInternalStatus()
    }
    
    private func startScanning() {
        guard let vc = visionScannerVC else {
            currentStatus = .error("Scanner not initialized")
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
            return
        }
        guard isSupported && hasPermissions() else {
            updateInternalStatus()
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
            return
        }
        
        if currentStatus != .ready && currentStatus != .scanning {
            if !currentStatus.isError {
                currentStatus = .error("Cannot scan: Scanner not ready. Status: \(currentStatus)")
            }
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
            return
        }

        // Check if already scanning to prevent issues, though DataScannerViewController handles this gracefully.
        if isScanning && vc.isScanning { return }

        do {
            try vc.startScanning()
            isScanning = true
            currentStatus = .scanning
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
        } catch {
            isScanning = false
            currentStatus = .error("Failed to start scanning: \(error.localizedDescription)")
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
        }
    }

    private func stopScanning() {
        guard let vc = visionScannerVC, vc.isScanning || isScanning else {
            if isScanning {
                isScanning = false
                updateInternalStatus()
                delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
            }
            return
        }
        vc.stopScanning()
        isScanning = false
        updateInternalStatus()
        delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
    }
    
    private func checkPermissions(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }

    private func updateInternalStatus() {
        if !isSupported {
            currentStatus = .error("Camera not supported")
        } else if !hasPermissions() {
            currentStatus = .error("Camera permission denied")
        } else if isScanning {
            currentStatus = .scanning
        } else {
            currentStatus = .ready
        }
    }

    private func hasPermissions() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
}

// Extension to check if ScannerStatus is an error type easily
extension ScannerStatus {
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
}
