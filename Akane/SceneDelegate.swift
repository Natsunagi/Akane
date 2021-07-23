//
//  SceneDelegate.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/11.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        #if iPadOS
        let rootViewController: AKRootSidebarViewController = AKRootSidebarViewController()
        let detailViewController: AKDetailViewController = AKDetailViewController()
        let leftNavigationController: AKUINavigationController = AKUINavigationController(rootViewController: rootViewController)
        leftNavigationController.navigationBar.prefersLargeTitles = true
        leftNavigationController.navigationBar.isTranslucent = true  // 毛玻璃效果如果弄成 false 的话，在 large title 的情况下上下滑动导航栏会卡。
        let rightNavigationController: AKUINavigationController = AKUINavigationController(rootViewController: detailViewController)
        let splitViewController: UISplitViewController = UISplitViewController(style: .doubleColumn)
        self.window?.rootViewController = splitViewController
        splitViewController.preferredDisplayMode = .automatic
        splitViewController.preferredPrimaryColumnWidthFraction = 0.3
        splitViewController.setViewController(leftNavigationController, for: .primary)
        splitViewController.setViewController(rightNavigationController, for: .secondary)
        detailViewController.files = AKManager.getAllMovies(location: AKManager.location)
        detailViewController.listType = .all
        detailViewController.playlistIndex = -1
        detailViewController.playlist = AKPlaylist.init(uuid: "All", name: "All")
        AKManager.splitViewController = splitViewController
        AKManager.leftNavigationController = leftNavigationController
        AKManager.rightNavigationController = rightNavigationController
        #endif
        
        #if iPhoneOS
        let rootViewController: AKRootSidebarViewController = AKRootSidebarViewController()
        let navigationController: AKUINavigationController = AKUINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.isTranslucent = true  // 毛玻璃效果如果弄成 false 的话，在 large title 的情况下上下滑动导航栏会卡。
        self.window?.rootViewController = navigationController
        #endif
        
        if AKManager.location == .iCloud {
            guard let _ = AKConstant.iCloudURL else {
                return
            }
        }
        
        AKManager.playlists = AKManager.getAllPlaylists(location: AKManager.location)
        
        AKFileOperation.shared.customAction()
        AKFileOperation.shared.clearTrash()
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
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        let url: URL = URLContexts.first!.url
//        let name: String = url.lastPathComponent.components(separatedBy: ".").first!
//        let movie: AKMovie = AKMovie.init(name: name, fileURL: url, fileLocation: .outsideContainer)
//        let playerViewController: AKPlayerViewController = AKPlayerViewController.init()
//        playerViewController.movie = movie
//        let navigationController: AKUINavigationController = self.window?.rootViewController as! AKUINavigationController
//        playerViewController.modalPresentationStyle = .fullScreen
//        navigationController.topViewController?.present(playerViewController, animated: true, completion: nil)
    }

}
