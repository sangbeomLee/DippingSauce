//
//  SceneDelegate.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/02.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        ConfigureInitialViewController()
    }

    // 어떤 뷰 컨트롤러를 내보낼 것인가.
    func ConfigureInitialViewController(){
        var initialVC: UIViewController
        var storyboard: UIStoryboard
        // user가 로그인 되어있는 경우
        if Auth.auth().currentUser != nil{
            storyboard = UIStoryboard.init(name: STORYBOARD_NAME_MESSAGE, bundle: nil)
            initialVC = storyboard.instantiateViewController(identifier: IDENTIFIER_TAPBAR)
        }else{
            storyboard = UIStoryboard.init(name: STORYBOARD_NAME_MAIN, bundle: nil)
            initialVC = storyboard.instantiateViewController(identifier: IDENTIFIER_MAIN)
        }
        window?.rootViewController = initialVC
        // 지금 올라와있는것 말고다른것들은 다 아래로 내린다.
        window?.makeKeyAndVisible()
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        Api.User.isOnline(bool: true)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        Api.User.isOnline(bool: false)
    }
    

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        Api.User.isOnline(bool: false)
    }


    

}

