import CoreBluetooth
import Foundation

public class CentralConnectionService: NSObject {
    private lazy var centralManager: CBCentralManager = .init(delegate: self, queue: nil)
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
}

extension CentralConnectionService: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
            let service = CBUUID(string: ServiceUUID)
            centralManager.scanForPeripherals(withServices: [service])
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

    public func centralManager(_ centralManager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData _: [String: Any], rssi _: NSNumber) {
        // TODO: confirm this is the correct device

        centralManager.connect(peripheral, options: nil)

        self.peripheral = peripheral
    }

    public func centralManager(_ centralManager: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager.stopScan()

        peripheral.delegate = self

        let service = CBUUID(string: ServiceUUID)

        peripheral.discoverServices([service])
    }
}

extension CentralConnectionService: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            print("Unable to discover services: \(error.localizedDescription)")
            // TODO: figure out what this function actually needs to do
            // cleanUp()
            return
        }

        let characteristic = CBUUID(string: CharacteristicUUID)

        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics([characteristic], for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error = error {
            print("Unable to discover characteristics: \(error.localizedDescription)")
            // cleanUp()
            return
        }

        let characteristicUUID = CBUUID(string: CharacteristicUUID)

        service.characteristics?.forEach { characteristic in
            guard characteristic.uuid == characteristicUUID else { return }

            peripheral.setNotifyValue(true, for: characteristic)

            self.characteristic = characteristic
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        
    }
}
