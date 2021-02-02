//
//  ContentView.swift
//  Shared
//
//  Created by Paul Krakow on 12/28/20.
//


// TODO Notes
// Search through all UPDATE comments
// The app is locked in portrait mode because there were issues with landscape mode
// Upgrade to use iCloud to persist results across devices

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selection: String? = nil
    
    // Retrieve stored habits from CoreData
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [
            // Note that the sort order is in place to make it easy to grab the latest entry in CoreData
            // Do not change this
            NSSortDescriptor(keyPath: \Habit.creationDate, ascending: false)
        ]
    ) var habits: FetchedResults<Habit>
    

    // Primary view for the app
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: WelcomeView(), tag: "Welcome", selection: $selection) { EmptyView() }
                Text("Simply Good Habits")
                    .font(.largeTitle)
                    .underline()
                NavigationLink(habits.first?.name ?? "First Good Habit", destination: EditView(), tag: "Edit", selection: $selection)
                Button(
                    action: { incrementHabitCount(); successPressed(impact); playSound(sound: "Bell-Tree", type: "mp3") },
                    label: { Text("\((habits.first?.count ?? 0))") }
                )
                .buttonStyle(DynamicRoundButtonStyle(bgColor: updateButtonColor()))
                .font(.largeTitle)
                .shadow(color: .dropShadow, radius: 15, x: 10, y: 10)
                .shadow(color: .dropLight, radius: 15, x: -10, y: -10)
                HStack {
                    Text("Target \(Text(habits.first?.moreOrLess ?? true ? ">=" : "<=")) \(habits.first?.target ?? 0)")
                    Spacer()
                    Button(
                        action: { decrementHabitCount() },
                        label: { Text("Undo") }
                    )
                    .buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .undo))
                }.padding()
            }
            // Hide the navigation bar
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .environment(\.managedObjectContext, viewContext)
        // When the app loads
        .onAppear() {
            //print("onAppear Fired")
            
            // Check if this is the first time the app has been used
            if habits.count == 0
            {
                print("First Use")
                // Create the first Habit entity in CoreData
                // Navigate to the WelcomeView to let the user setup the first good habit
                self.selection = "Welcome"
            }
            
            // Check if it is a new day, and if so, setup the app for the new day
            if newDayDetector() {
                startNewDay()
            }
            
        }
        // When the app moves to the foreground
        .onReceive(NotificationCenter.default.publisher(for:
            UIApplication.willEnterForegroundNotification)) { _ in
            
            // Check if it is a new day, and if so, setup the app for the new day
            if newDayDetector() {
                startNewDay()
            }
            
        }
        
    }
    
    // Determine if the app is being used on a new  day compared to the last use
    func newDayDetector() -> Bool {
        // Lookup what year, month and day it is right now
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        // Lookup the latest entry
        let dayOfLastEntry = formatter.string(from: habits.first?.creationDate ?? Date())
        
        // Check if it was from a day other than today
        if dayOfLastEntry != today {
            return true
        } else {
            return false
        }
    }
    
    // Prep the app for a new day of use
    func startNewDay() -> Void {
        // Create a new habit entry that takes the persistent elements of the last entry, and updates the creationDate and count for the new day
        addHabit(uuid: (habits.first?.uuid)!, creationDate: Date(), name: (habits.first?.name)!, moreOrLess: (habits.first?.moreOrLess)!, target: (habits.first?.target)!, count: 0)
        saveContext()
    }
    
    // Increase the habit count by 1
    func incrementHabitCount() -> Void {
        habits.first?.count += 1
        saveContext()
    }
    
    // Decrease the habit count by 1
    func decrementHabitCount() -> Void {
        if habits.first?.count ?? 0 > 0 {
            habits.first?.count -= 1
            saveContext()
        }
    }
    
    // Change the button color to reflect how the habit.count relates to the habit.target
    func updateButtonColor() -> Color {
        let updateCount = Double(habits.first?.count ?? 0)
        var updateTarget = Double(habits.first?.target ?? 0)
        // Safety net to protect against NaN scenarios and negative targets
        if (updateTarget < 0.001) {
            updateTarget = 0.001
        }
        let updateMore = min((updateCount/updateTarget)/2,0.5)
        let updateLessA = min((updateCount/updateTarget)/2,1)
        var updateLessB : Double
        
        // Logic to generate updateLessB
        if (updateCount <= updateTarget) {
            updateLessB = 0
        } else {
            updateLessB = min((updateCount - updateTarget)/updateTarget, 1)
        }
        var updateColor = Color.gray

        // If the user is trying to do something more:
        if habits.first?.moreOrLess ?? true {
            // Transition from grey (0) to green (target)
            updateColor = Color(red: (0.5 - updateMore), green: (0.5 + updateMore), blue: (0.5 - updateMore), opacity: 1)
        } else {
            // If the user is trying to do something less, transition from green to yellow to red (@2x the target)
            updateColor = Color(red: updateLessA, green: (1 - updateLessB), blue: 0, opacity: 1)
        }
        return updateColor
    }
    
    // Save habits to CoreData
    public func saveContext() {
      do {
        try viewContext.save()
      } catch {
        print("Error saving managed object context: \(error)")
      }
    }
    
    // Add a new habit
    public func addHabit(uuid: UUID, creationDate: Date, name: String, moreOrLess: Bool,  target: Int64, count: Int64) {
        // Create a newHabit object
        let newHabit = Habit(context: viewContext)
        
        // Populate the attributes of the newHabit
        newHabit.uuid = UUID()
        newHabit.creationDate = Date()
        newHabit.name = name
        newHabit.moreOrLess = moreOrLess
        newHabit.target = target
        newHabit.count = count
        
        // Save all of the habits including the new one
        saveContext()
    }
    
    // Delete a habit
    public func deleteHabit(at offsets: IndexSet) {
        // Go through the CoreData index to find and delete the specific habit
        offsets.forEach { index in
            let habit = self.habits[index]
            self.viewContext.delete(habit)
      }
      
        // Save the updated list of habits to CoreData
      saveContext()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext,
            PersistenceController.preview.container.viewContext)
    }
}




