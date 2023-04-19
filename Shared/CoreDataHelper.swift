//
//  CoreDataHelper.swift
//  Simply Good Habits
//
//  Created by Paul Krakow on 4/18/23.
//

import Foundation
import CoreData
import SwiftUI

struct CoreDataHelper {
    
    // Save context to CoreData
    static func saveContext(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
    
    // Add a new habit
    static func addHabit(context: NSManagedObjectContext, uuid: UUID, creationDate: Date, name: String, moreOrLess: Bool, target: Int64, count: Int64) {
        let newHabit = Habit(context: context)
        
        newHabit.uuid = UUID()
        newHabit.creationDate = Date()
        newHabit.name = name
        newHabit.moreOrLess = moreOrLess
        newHabit.target = target
        newHabit.count = count
        
        saveContext(context: context)
    }
    
    // Delete a habit
    static func deleteHabit(context: NSManagedObjectContext, habit: Habit) {
        context.delete(habit)
        saveContext(context: context)
    }
}
