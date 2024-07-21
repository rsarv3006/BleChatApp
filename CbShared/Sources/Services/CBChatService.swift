import CoreBluetooth
import Foundation

public enum CBChatState {
    case Scanning
    case Advertising
    case CentralChat
    case PeripheralChat
}

public class CBChatService: NSObject {
    public var onMessageReceived: ((String) -> Void)?
    private var targetDevice: CBDevice?
    private var state = CBChatState.Scanning

    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?

    private var central: CBCentral?
    private var peripheral: CBPeripheral?

    private var centralCharacteristic: CBCharacteristic?
    private var peripheralCharacteristic: CBMutableCharacteristic?

    private var pendingMessageData: Data?

    public init(target: CBDevice) {
        super.init()
        targetDevice = target
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    public func send(_ message: String) {
        guard let messageData = message.data(using: .utf8) else { return }

        switch state {
        case .Scanning:
            pendingMessageData = messageData
            startAdvertising()
        case .Advertising:
            pendingMessageData = messageData
        case .CentralChat:
            sendFromCentralToPeripheral(messageData)
        case .PeripheralChat:
            sendFromCentralToPeripheral(messageData)
        }
    }

    private func startAdvertising() {
        guard state == .Scanning, peripheralManager == nil else { return }
        state = .Advertising
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    private func sendFromCentralToPeripheral(_ data: Data) {
        guard let characteristic = centralCharacteristic,
              let peripheral
        else { return }

        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    private func sendFromPeripheralToCentral(_ data: Data) {
        guard let characteristic = peripheralCharacteristic,
              let central
        else { return }

        peripheralManager?.updateValue(data, for: characteristic, onSubscribedCentrals: [central])
    }
}

extension CBChatService: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }

        guard central.isScanning == false else { return }

        startScan()
    }

    public func centralManager(_: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData _: [String: Any], rssi _: NSNumber) {
        guard peripheral.identifier == targetDevice?.peripheral.identifier else { return }

        centralManager?.connect(peripheral, options: nil)

        self.peripheral = peripheral

        state = .CentralChat
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        central.stopScan()

        peripheral.delegate = self

        peripheral.discoverServices([ChatServiceId])
    }

    public func centralManager(_: CBCentralManager, didFailToConnect _: CBPeripheral, error: (any Error)?) {
        if let error {
            print(error.localizedDescription)
        }

        resetCentral()
        startScan()
    }

    public func centralManager(_: CBCentralManager, didDisconnectPeripheral _: CBPeripheral, error: (any Error)?) {
        if let error {
            print(error.localizedDescription)
        }

        resetCentral()
        startScan()
    }

    private func resetCentral() {
        state = .Scanning
        peripheral = nil
    }

    private func startScan() {
        guard let centralManager, !centralManager.isScanning else {
            print("Device already scanning")
            return
        }

        centralManager.scanForPeripherals(withServices: [ChatServiceId],
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
}

extension CBChatService: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else { return }

        peripheralCharacteristic = CBMutableCharacteristic(
            type: ChatCharacteristicID,
            properties: [.write, .notify],
            value: nil,
            permissions: .writeable
        )

        let service = CBMutableService(
            type: ChatServiceId,
            primary: true
        )
        guard let peripheralCharacteristic = peripheralCharacteristic else { return }
        service.characteristics = [peripheralCharacteristic]

        peripheralManager?.add(service)

        let advertisementData: [String: Any] = [CBAdvertisementDataServiceUUIDsKey: [ChatServiceId]]
        peripheralManager?.startAdvertising(advertisementData)
    }

    public func peripheralManager(_: CBPeripheralManager, central: CBCentral, didSubscribeTo _: CBCharacteristic) {
        print("Subcription")

        centralManager?.stopScan()

        state = .PeripheralChat

        self.central = central

        if let data = pendingMessageData {
            sendFromPeripheralToCentral(data)
            pendingMessageData = nil
        }
    }

    public func peripheralManager(_: CBPeripheralManager, central _: CBCentral, didUnsubscribeFrom _: CBCharacteristic) {
        print("The central has unsubscribed from the peripheral")

        central = nil

        centralManager?.scanForPeripherals(withServices: [ChatServiceId],
                                           options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    public func peripheralManager(_: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        guard let request = requests.first, let data = request.value else { return }

        // Decode the message string and trigger the callback
        let message = String(decoding: data, as: UTF8.self)
        onMessageReceived?(message)
    }
}

extension CBChatService: CBPeripheralDelegate {
    private func cleanUp() {
        guard let peripheral, peripheral.state != .disconnected else { return }

        peripheral.services?.forEach { service in
            service.characteristics?.forEach { characteristic in
                if characteristic.uuid != ChatCharacteristicID { return }
                if characteristic.isNotifying {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error {
            print(error.localizedDescription)
            cleanUp()
            return
        }

        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics([ChatCharacteristicID], for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error {
            print(error.localizedDescription)
            cleanUp()
            return
        }

        service.characteristics?.forEach { characteristic in
            guard characteristic.uuid == ChatCharacteristicID else { return }

            peripheral.setNotifyValue(true, for: characteristic)

            self.centralCharacteristic = characteristic
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Characteristic value update failed: \(error.localizedDescription)")
            return
        }

        guard let data = characteristic.value else { return }
        let message = String(decoding: data, as: UTF8.self)
        onMessageReceived?(message)
    }

    public func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {
        // Perform any error handling if one occurred
        if let error = error {
            print("Characteristic update notification failed: \(error.localizedDescription)")
            return
        }

        guard characteristic.uuid == ChatCharacteristicID else { return }

        if characteristic.isNotifying {
            print("Characteristic notifications have begun.")
        } else {
            print("Characteristic notifications have stopped. Disconnecting.")
            centralManager?.cancelPeripheralConnection(peripheral)
        }

        if let data = pendingMessageData {
            sendFromCentralToPeripheral(data)
            pendingMessageData = nil
        }
    }
}
