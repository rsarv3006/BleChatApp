import CoreBluetooth
import Foundation

public let ServiceUUID = "548266da-fe5b-427e-beac-2c0223664aad"
public let CharacteristicUUID = "ed5e2db8-f1ab-4f9d-bcba-92d2de7929e8"

public enum DeviceConnectionType {
    case Peripheral
    case Central
    case Both
}

public class CbService: NSObject {
    private let connectionType: DeviceConnectionType
    private let centralConnectionService: CentralConnectionService?
    private let peripheralManager: CBPeripheralManager?

    public init(connectionType: DeviceConnectionType) {
        self.connectionType = connectionType

        if connectionType == .Central {
            centralConnectionService = CentralConnectionService()
        } else {
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }
    }
}

extension CbService: CBPeripheralManagerDelegate {
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

            peripheralManager?.add(service)

            peripheralManager?.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [service],
                CBAdvertisementDataLocalNameKey: "Device Information"
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
