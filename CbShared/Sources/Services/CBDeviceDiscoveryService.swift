import CoreBluetooth
import Foundation

public class CBDeviceDiscoveryService: NSObject {
    private static let QueueName = "live.rjs.ble.chat-app"

    public var deviceName: String {
        didSet { startAdvertising() }
    }

    public private(set) var devices: [CBDevice] = []

    public var onDevicesUpdated: (() -> Void)?

    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?

    private let cbQueue = DispatchQueue(label: QueueName,
                                        qos: .background,
                                        attributes: .concurrent,
                                        autoreleaseFrequency: .workItem,
                                        target: nil)

    public init(deviceName: String) {
        self.deviceName = deviceName
        super.init()

        centralManager = CBCentralManager(delegate: self, queue: cbQueue)
        peripheralManager = CBPeripheralManager(delegate: self, queue: cbQueue)
        
        startAdvertising()
    }

    private func startAdvertising() {
        guard let peripheralManager else { return }
        guard peripheralManager.state == .poweredOn else { return }

        if peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
        }

        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [DiscoveryServiceId],
            CBAdvertisementDataLocalNameKey: deviceName,
        ])
    }

    private func updateDeviceList(device: CBDevice) {
        if let index = devices.firstIndex(where: { $0.peripheral.identifier == device.peripheral.identifier }) {
            guard devices[index].deviceName != device.deviceName else { return }
            devices.remove(at: index)
            devices.insert(device, at: index)
        } else {
            devices.append(device)
        }

        onDevicesUpdated?()
    }
}

extension CBDeviceDiscoveryService: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        
        centralManager?.scanForPeripherals(withServices: [DiscoveryServiceId], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    public func centralManager(_: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi _: NSNumber) {
        var name = peripheral.identifier.description

        if let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            name = deviceName
        }

        let device = CBDevice(deviceName: name, peripheral: peripheral)

        DispatchQueue.main.async { [weak self] in
            self?.updateDeviceList(device: device)
        }
    }
}

extension CBDeviceDiscoveryService: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else { return }

        startAdvertising()
    }
}
