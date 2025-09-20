import UIKit
import Flutter

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    // Storyboard（Main.storyboard）を使うので、ここは何もしなくてOK。
    // FlutterViewController は Storyboard の Initial View Controller になります。
    guard scene is UIWindowScene else { return }
  }
}
