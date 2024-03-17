import SwiftUI

@main
struct MyView: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onDisappear {
                #if os(macOS)
                    exit(0)
                #endif
            }
        }
    }
}
