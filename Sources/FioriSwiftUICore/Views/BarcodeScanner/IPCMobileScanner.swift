import SwiftUI
import CoreBluetooth
#if canImport(RapidScanCompanion)
import RapidScanCompanion

@MainActor
public final class IPCMobileScanner: NSObject, BarcodeScanner {
    public let type: ScannerType = .ipcMobile
    public weak var delegate: (any BarcodeScannerDelegate)?
    public private(set) var currentStatus: ScannerStatus = .poweredOff

    private let companion: RSCompanion?
    private var connectedHalos: [String] = []
    private var isScannerReady: Bool = false

    public override init() {
//        #if canImport(RapidScanCompanion)
        self.companion = RSCompanion(serviceUUID: CBUUID(string: "f7b5a183-772f-4990-8b36-b98a4c40f890"))
        super.init()
        self.companion?.delegate = self
//        #else
//        self.companion = nil
//        super.init()
//        self.currentStatus = .error("RapidScanCompanion SDK not available")
//        #endif
    }

    public func startMonitoring() {
        guard let companion = companion else {
            currentStatus = .error("RapidScanCompanion SDK not available")
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
            return
        }
        companion.startAdvertising()
        updateInternalStatus()
        delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
    }

    public func stopMonitoring() {
        companion?.stopAdvertising()
        reset()
    }

    public func reset() {
        connectedHalos.removeAll()
        isScannerReady = false
        companion?.stopAdvertising()
        updateInternalStatus()
        delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
    }

    public func getPairingQRCode() -> Image? {
        guard let companion = companion else {
            currentStatus = .error("RapidScanCompanion SDK not available")
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
            return nil
        }
        guard let uiImage = companion.generatePairingQRCodeImage() else {
            currentStatus = .error("Failed to generate QR code for pairing")
            delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
            return nil
        }
        companion.startAdvertising()
        let qrImage = Image(uiImage: uiImage)
        updateInternalStatus()
        delegate?.barcodeScannerDidUpdateStatus(currentStatus, for: self)
        return qrImage
    }

    public func updateDisplay(message: String) {
        guard isScannerReady, !connectedHalos.isEmpty, companion != nil else {
            print("No connected IPCMobile scanner to update display.")
            return
        }
        let card = RSRislCard(width: 290, height: 150)
        card.setBackgroundColor("#004F94")
        card.setFont(size: 48, color: "#FFFFFF", bold: true, underline: false)
        card.textCenter(y: 10, text: message)
        card.playGoodSound()
        card.showCard()
        companion?.sendRislCards([card], toHalos: connectedHalos)
    }

    public func isAvailable() -> Bool {
        companion != nil && isScannerReady && currentStatus == .ready
    }
}

extension IPCMobileScanner: RSCompanionDelegate {
    public func rsCompanionState(_ state: RSCompanionState, uuid: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch state {
            case .ready:
                self.isScannerReady = false
                self.companion?.startAdvertising()
                self.updateInternalStatus()
                self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
            case .connected:
                if !self.connectedHalos.contains(uuid) {
                    self.connectedHalos.append(uuid)
                }
                self.isScannerReady = true
                self.updateInternalStatus()
                self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
            case .disconnected:
                self.connectedHalos.removeAll { $0 == uuid }
                self.isScannerReady = !self.connectedHalos.isEmpty
                self.updateInternalStatus()
                self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
            case .advertising:
                self.updateInternalStatus()
                self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
            default:
                self.isScannerReady = false
                self.updateInternalStatus()
                self.delegate?.barcodeScannerDidUpdateStatus(self.currentStatus, for: self)
            }
        }
    }

    public func rsCompanionDidReceiveBarcode(_ barcode: String, symbology: String, serial: String, verb: String, uuid: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let scanResult = "\(barcode) - Symbology: \(symbology)"
            self.delegate?.barcodeScannerDidReceiveBarcode(scanResult, from: self)

            // Display barcode on scanner
            let card = RSRislCard(width: 290, height: 150)
            card.setBackgroundColor("#84D400")
            card.text(barcode, verticlePosition: 8, alignment: .center, font: RSRislCard.encodeFont(size: 36, color: "#000000", bold: true, underline: false))
            card.text("Symbology: \(symbology)", verticlePosition: 100, alignment: .center, font: RSRislCard.encodeFont(size: 28, color: "#000000", bold: false, underline: false))
            card.playGoodSound()
            card.showCard()
            self.companion?.sendRislCards([card], toHalos: self.connectedHalos)
        }
    }

    public func rsCompanionDidReceiveImage(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let card = RSRislCard(width: 290, height: 150)
            card.setBackgroundColor("#004F94")
            card.setFont(size: 48, color: "#FFFFFF", bold: true, underline: false)
            card.textCenter(y: 10, text: "Image Received")
            card.playGood2Sound()
            card.showCard()
            self.companion?.sendRislCards([card], toHalos: self.connectedHalos)
        }
    }

    public func rsCompanionDidReceiveButtonPress(_ button: RSButton, serial: String, uuid: String) {}
    public func rsCompanionDidReceiveRislButtonPress(_ button: String, serial: String, uuid: String) {}
    public func rsCompanionDidReceiveVerbSelection(_ verb: String, serial: String, uuid: String) {}
}

private extension IPCMobileScanner {
    func updateInternalStatus() {
        if companion == nil {
            currentStatus = .error("RapidScanCompanion SDK not available")
        } else if !isScannerReady {
            currentStatus = connectedHalos.isEmpty ? .poweredOn : .disconnected
        } else {
            currentStatus = .ready
        }
    }
}
#endif
