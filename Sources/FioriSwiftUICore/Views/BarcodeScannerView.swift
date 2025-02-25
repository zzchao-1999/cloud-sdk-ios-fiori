import SwiftUI

public struct BarcodeScannerView: View {
    @State private var textFieldText: String = ""
    @State private var isScanning: Bool = false

    public init() {}
    
    public var body: some View {
        VStack {
            TextField("Enter text or scan result", text: $textFieldText)
               .textFieldStyle(RoundedBorderTextFieldStyle())
               .padding()

            Button(action: {
                // Simulate scanning action
                self.isScanning = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.textFieldText = "Scanned result"
                    self.isScanning = false
                }
            }) {
                if isScanning {
                    Text("Scanning...")
                } else {
                    Text("Scan")
                }
            }
           .padding()
        }
    }
}

struct ContentView: View {
    var body: some View {
        BarcodeScannerView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
