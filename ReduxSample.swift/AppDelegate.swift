//
//  AppDelegate.swift
//  ReduxSample.swift
//
//  Created by Yusuke Binsaki on 2019/06/06.
//  Copyright © 2019 Yusuke Binsaki. All rights reserved.
//

import UIKit
import CoreData
import ReSwift

let loggingMiddleware: Middleware<Any> = { dispatch, getState in
    return { next in
        return { action in
            print("Action:", action)
            return next(action)
        }
    }
}

struct AppState: StateType {
    var counterState = CounterState()
    var otherState = OtherState()
}

struct CounterState: StateType {
    var counter: Int = 0
}

extension AppState {
    static func reducer(action: Action, state: AppState?) -> AppState {
        var state = state ?? AppState()
        if case is CounterActionIncrease = action {
            state.counterState = CounterState.reducer(action: action, state: state.counterState)
        }
        if case is CounterActionDecrease = action {
            state.counterState = CounterState.reducer(action: action, state: state.counterState)
        }

        if case is OtherAction = action {
            state.otherState = OtherState.reducer(action: action, state: state.otherState)
        }

        return state
    }
}

extension CounterState {
    static func reducer(action: Action, state: CounterState?) -> CounterState {
        var state = state ?? CounterState()

        switch action {
        case _ as CounterActionIncrease:
            state.counter += 1
        case _ as CounterActionDecrease:
            state.counter -= 1
        default:
            break
        }
        print("counter reducer state=\(state.counter)")

        return state
    }
}

struct OtherState {}
extension OtherState {
    static func reducer(action: Action, state: OtherState?) -> OtherState {
        let state = state ?? OtherState()
        guard let action = action as? OtherAction else {
            print("other reducer nothing")
            return state
        }

        switch action {
        case let .Ok(x):
            print("other reducer=\(x)")
            return state
        case let .Err(msg):
            print("other reducer=\(msg)")
            return state
        }
    }
}

let mainStore = Store<AppState>(
    reducer: AppState.reducer,
    state: nil,
    middleware: [loggingMiddleware]
)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ReduxSample_swift")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

