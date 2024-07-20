import Foundation
import CoreBluetooth

public struct CBDevice {
    let deviceName: String
    let peripheral: CBPeripheral
    
    init(deviceName: String, peripheral: CBPeripheral) {
        self.deviceName = deviceName
        self.peripheral = peripheral
    }
}
