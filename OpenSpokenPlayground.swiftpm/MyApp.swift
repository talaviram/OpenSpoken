import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onDisappear {
                // macOS should terminate app when closing window
                #if os(macOS)
                    exit()
                #endif
            }
        }
    }
}
