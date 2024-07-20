import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
                JoinScreen()
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
