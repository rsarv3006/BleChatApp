import Foundation
import CoreBluetooth

public struct CBDevice: Identifiable {
    public var id: ObjectIdentifier

    public let deviceName: String
    public let peripheral: CBPeripheral
    
    init(deviceName: String, peripheral: CBPeripheral) {
        self.deviceName = deviceName
        self.peripheral = peripheral
        self.id = ObjectIdentifier(peripheral)
    }
}

extension CBDevice: Equatable {
    public static func == (lhs: CBDevice, rhs: CBDevice) -> Bool {
        return lhs.id == rhs.id && lhs.deviceName == rhs.deviceName
        // Add other relevant properties
    }
}
