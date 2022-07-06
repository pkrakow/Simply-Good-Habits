//
//  CoreDataManager.swift
//  Simply Good Habits
//
//  Created by Paul on 8/29/21.
//

// https://stackoverflow.com/questions/50950122/swift-core-data-class-method/50960726

import Foundation
import Combine
import CoreData
import WatchConnectivity


/*
final class CoreDataManager: ObservableObject {
    
    // These variables are for WatchConnectivity
    var session: WCSession
    let delegate: WCSessionDelegate
    let subject = PassthroughSubject<Int, Never>()
    
    @Published private(set) var count: Int = 0
    
    init(session: WCSession = .default) {
        self.delegate = SessionDelegator(countSubject: subject)
        self.session = session
        self.session.delegate = self.delegate
        self.session.activate()
        
        subject
            .receive(on: DispatchQueue.main)
            .assign(to: &$count)
    }
}
*/
/*
class CoreDataManager:NSObject{
/// Application Document directory
lazy var applicationDocumentsDirectory: URL = {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1]
}()
/// Core data manager
static var shared = CoreDataManager()
/// Managed Object Model
lazy var managedObjectModel: NSManagedObjectModel = {

    let modelURL = Bundle.main.url(forResource: "your DB name”, withExtension: ",momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
}()
/// Persistent Store Coordinator
lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    let options = [ NSInferMappingModelAutomaticallyOption : true,
                    NSMigratePersistentStoresAutomaticallyOption : true]
    do {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        persistanceStoreKeeper.sharedInstance.persistanceStorePath = url
    } catch {
        var dict = [String: AnyObject]()
        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
        dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
        dict[NSUnderlyingErrorKey] = error as NSError
        let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
        abort()
    }
    return coordinator
}()
/// Managed Object Context
lazy var managedObjectContext: NSManagedObjectContext = {

    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
}()
/// Save context
func saveContext () {
    if managedObjectContext.hasChanges {
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
}
    
}
*/
