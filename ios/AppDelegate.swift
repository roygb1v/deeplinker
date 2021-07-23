//
//  AppDelegate.swift
//  emcdormakaba
//
//  Created by Roy Cheong on 23/7/21.
//

import UIKit

import AppsFlyerLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var bridge: RCTBridge!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let jsCodeLocation: URL
    
//    AppsFlyerLib.shared().appsFlyerDevKey = "<DEV_KEY>"
//    AppsFlyerLib.shared().appleAppID = "<APPID>"
    
    AppsFlyerLib.shared().delegate = self
    AppsFlyerLib.shared().isDebug = true
    
    // iOS 10 or later
    if #available(iOS 10, *) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in }
        application.registerForRemoteNotifications()
    }
    // iOS 9 support - Given for reference. This demo app supports iOS 13 and above
    else {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        UIApplication.shared.registerForRemoteNotifications()
    }

    jsCodeLocation = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index", fallbackResource:nil)
    let rootView = RCTRootView(bundleURL: jsCodeLocation, moduleName: "emcdormakaba", initialProperties: nil, launchOptions: launchOptions)
    let rootViewController = UIViewController()
    rootViewController.view = rootView

    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.rootViewController = rootViewController
    self.window?.makeKeyAndVisible()

    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
      // Start the SDK (start the IDFA timeout set above, for iOS 14 or later)
      AppsFlyerLib.shared().start()
  }
  
  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
      return true
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
      return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      AppsFlyerLib.shared().handleOpen(url, options: options)
      return true
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      AppsFlyerLib.shared().handlePushNotification(userInfo)
  }
}

extension AppDelegate: AppsFlyerLibDelegate {
    // Handle Organic/Non-organic installation
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        print("onConversionDataSuccess data:")
        for (key, value) in data {
            print(key, ":", value)
        }
        if let status = data["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = data["media_source"],
                    let campaign = data["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = data["is_first_launch"] as? Bool,
                is_first_launch {
                print("First Launch")
            } else {
                print("Not First Launch")
            }
        }
    }
    func onConversionDataFail(_ error: Error) {
        print("\(error)")
    }
    // Handle Deeplink
    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        //Handle Deep Link Data
        print("onAppOpenAttribution data:")
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    func onAppOpenAttributionFailure(_ error: Error) {
        print("\(error)")
    }
}
