import SwiftUI
import UIKit

// SwiftUI template with fallback to support iOS 13
// https://stackoverflow.com/questions/69703928/how-to-generate-ios-13-swiftui-project-in-xcode

@main
struct MainApp {
    static func main() {
            UIApplicationMain(
                CommandLine.argc,
                CommandLine.unsafeArgv,
                nil,
                NSStringFromClass(AppDelegate.self))
    }
}

@available(iOS 14.0, *)
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

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = ContentView()

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        //
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        //
    }

    func sceneWillResignActive(_ scene: UIScene) {
        //
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        //
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        //
    }
}
