//
//  AppDelegate.swift
//  iOSApp
//
//  Created by Naveen Chauhan on 12/10/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window:UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
         let controller = ProfileTemplateController()
         window?.rootViewController = controller
         window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let isTemplatetStored = UserDefaultHelper.isTemplateStored
        
        /* THIS CHECKS TO SEE IF TEMPLATE IS OLD OR NEW
        let templateLookup:TemplateLookup = TemplateLookup(context:"ANYY VIEW CONTROLLER INSTANCE")
       
        if(!isTemplatetStored){
            templateLookup.generateHybridModel()
        }else{
            templateLookup.checkAndUpdateHybridModel()
        }
        **/
        
        
    }


}

