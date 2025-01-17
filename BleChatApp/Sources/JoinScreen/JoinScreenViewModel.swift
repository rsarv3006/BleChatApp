import CbShared
import SwiftUI

public class JoinScreenViewModel: ObservableObject {
    @Published var displayName: String

    @Published var foundDevices: [CBDevice] = []

    @Published var discoveryService: CBDeviceDiscoveryService

    init() {
        let initialDisplayName = UIDevice.current.name
        displayName = initialDisplayName
        discoveryService = CBDeviceDiscoveryService(deviceName: initialDisplayName)

        discoveryService.onDevicesUpdated = { [weak self] in
            DispatchQueue.main.async {
                guard let self else {
                    print("self is nil")
                    return
                }

                let foundDevices = self.discoveryService.devices

                print(foundDevices.map { device in
                    device.deviceName
                })
                self.foundDevices = foundDevices
            }
        }
    }

    public func onDisplayNameChanged() {
        if displayName.isEmpty {
            displayName = UIDevice.current.name
        }

        discoveryService.deviceName = displayName
    }
}
