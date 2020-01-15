//
//  AppDelegate.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/02.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm_messageId"
    static var isToken: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        // availabel ios 10.0 하나하나 알아볼 것
        if #available(iOS 10.0, *){
            let current = UNUserNotificationCenter.current()
            let option: UNAuthorizationOptions = [.sound, .badge, .alert]
            
            current.requestAuthorization(options: option) { (granted, error) in
                if error != nil{
                    print("requestAuthorization\(error!.localizedDescription)")
                }else{
                    Messaging.messaging().delegate = self
                    current.delegate = self
                    DispatchQueue.main.async{
                        application.registerForRemoteNotifications()
                    }
                }
            }
        }else{
            let type: UIUserNotificationType = [.sound, .badge, .alert]
            let setting = UIUserNotificationSettings(types: type, categories: nil)
            application.registerUserNotificationSettings(setting)
            application.registerForRemoteNotifications()
        }
        
        // for FacebookLogin
        // 이렇게 바뀌었다 기억하자!
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        return true
    }
    // for facebookLogin
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        return handled
    }

    // 새로만듬
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFirebase()
    }
    // MARK: UISceneSession Lifecycle
    func applicationWillEnterForeground(_ application: UIApplication) {
        disConnectToFirebase()
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let messageID = userInfo[gcmMessageIDKey]{
            print("MessageID : \(messageID)")
        }
        print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey]{
            print("MessageID : \(messageID)")
        }
        connectToFirebase()
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let token = AppDelegate.isToken {
            
        }
    
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailRegisterForRemoteNotifications\(error.localizedDescription)")
    }
    
    func connectToFirebase(){
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    func disConnectToFirebase(){
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
}

extension AppDelegate:  UNUserNotificationCenterDelegate, MessagingDelegate{
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let message = userInfo[gcmMessageIDKey]{
            print("Message : \(message)")
        }
        
        print("usrInfo\(userInfo)")
        completionHandler([.sound, .badge, .alert])
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if error != nil{
                print(error!.localizedDescription)
            }
            let token = result?.token
            print("1111")
            AppDelegate.isToken = token
        }
        
        connectToFirebase()
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("didReceive remoteMessage \(remoteMessage.appData)")
    }
    
}
