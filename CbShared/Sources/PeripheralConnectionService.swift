import CoreBluetooth
import Foundation

public class PeripheralConnectionService: NSObject {
    private lazy var peripheralManager: CBPeripheralManager = .init(delegate: self, queue: nil)
}

extension PeripheralConnectionService: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Bluetooth is powered on")
            let characteristicId = CBUUID(string: CharacteristicUUID)
            let characteristic = CBMutableCharacteristic(type: characteristicId,
                                                         properties: [.write, .notify],
                                                         value: nil,
                                                         permissions: .writeable)
            let serviceId = CBUUID(string: ServiceUUID)
            let service = CBMutableService(type: serviceId, primary: true)
            service.characteristics = [characteristic]
            peripheralManager.add(service)
            peripheralManager.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [service],
                CBAdvertisementDataLocalNameKey: "Device Information",
            ])
        case .poweredOff:
            print("Bluetooth is powered off")
        case .unsupported:
            print("Bluetooth is not supported on this device")
        case .unauthorized:
            print("Bluetooth usage is not authorized")
        case .resetting:
            print("Bluetooth is resetting")
        case .unknown:
            print("Bluetooth state is unknown")
        @unknown default:
            print("Unknown Bluetooth state")
        }
    }
}
