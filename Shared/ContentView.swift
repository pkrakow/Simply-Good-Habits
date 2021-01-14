//
//  ContentView.swift
//  Shared
//
//  Created by Paul Krakow on 12/28/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    // Data for this view controller
    @State var habitCount = 0
    @State var yesterdayHabitCount = 0
    @State var habitDictionary = [Date:Int]()
    @State var moreOrLess = true
    @State var yesterdaysHabitCount = 0
    let habitTarget = 5
    


    // After that, build out the logic to change the button color based on the previous target
    
    
    var body: some View {
        VStack {
            Text("Simply Good Habits")
                .font(.largeTitle)
            Button(
                action: { incrementHabitCount() },
                label: { Text("\(habitCount)") }
            )
            .buttonStyle(DynamicRoundButtonStyle())
            HStack {
                Button(
                    action: { moreOrLess = true },
                    label: { Text("doMore") }
                ).buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doMore, moreOrLess: moreOrLess))
                Button(
                    action: { moreOrLess = false },
                    label: { Text("doLess") }
                        )
                .buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doLess, moreOrLess: moreOrLess))
                Spacer()
                Button(
                    action: { decrementHabitCount() },
                    label: { Text("Undo") }
                )
                .buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .undo))
            }.padding()
        }
    }
    
    
    func newDayDetector() -> Bool {
        // Lookup what year, month and day it is right now
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        // Lookup the latest entry in the habitDictionary
        let latestHabitDictionaryEntry = habitDictionary.max { a, b in a.key < b.key }
        let dayOfLastEntry = formatter.string(from: latestHabitDictionaryEntry?.key ?? Date())
        
        // Check if it was from a day other than today
        if dayOfLastEntry != today {
            return true
        } else {
            return false
        }
    }
    
    func incrementHabitCount() -> Void {
        
        // Check if it was from a day other than today
        if newDayDetector() {
            yesterdaysHabitCount = habitCount
            habitCount = 1
        } else {
            habitCount += 1
        }
        habitDictionary[Date()] = 1
        //print("habitCount \(habitCount)")
        //print("habitDictionary: \(habitDictionary)")
    }
    
    func decrementHabitCount() -> Void {
        
        // Check if it was from a day other than today
        if newDayDetector() {
            yesterdaysHabitCount = habitCount
            habitCount = 0
        } else {
            if habitCount > 0 {
                habitCount -= 1
                habitDictionary[Date()] = -1
            } else {
                habitCount = 0
            }
        }

        //print("habitCount \(habitCount)")
        //print("habitDictionary: \(habitDictionary)")
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


/*
struct Color {
    let red, green, blue: Double
    init(red: Double, green: Double, blue: Double) {
        self.red   = red
        self.green = green
        self.blue  = blue
    }
    init(white: Double) {
        red   = white
        green = white
        blue  = white
    }
}

let karl = Color(red: 1.0, green: 0.0, blue: 1.0)
*/

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext,
            PersistenceController.preview.container.viewContext)
    }
}




