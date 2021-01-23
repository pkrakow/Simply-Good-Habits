//
//  ContentView.swift
//  Shared
//
//  Created by Paul Krakow on 12/28/20.
//


// TODO Notes
// Search through all UPDATE comments
// Upgrade to use iCloud to persist results across devices
// After that, build out the logic to change the button color based on the previous target

import SwiftUI
import CoreData

// Welcome View that shows the first time a user opens the app
struct WelcomeView: View {
    var body: some View {
        VStack {
            Text("Simply Good Habits")
                .font(.largeTitle)
                .underline()
                .padding()
            Text("Welcome to a simple app that helps you build good daily habits.")
            Text("To get started, please fill out this little survey on the habit you would like to work on:")
            /*
             // UPDATE SOON: Add a form to setup the new habit
             // and add nav to go to the ContentView
            GroupBox(label: firstNewHabit) {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Content")/*@END_MENU_TOKEN@*/
            }
             */
        }
    }
}

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
    
    // UPDATE SOON: Get rid of these state values
    // Data for this view controller
    @State var habitCount: Int64 = 0
    @State var yesterdayHabitCount = 0
    @State var habitDictionary = [Date:Int]()
    @State var moreOrLess = true

    
    // Primary view for the app
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: WelcomeView(), tag: "Welcome", selection: $selection) { EmptyView() }
                Text("Simply Good Habits")
                    .font(.largeTitle)
                    .underline()
                Button(
                    action: { incrementHabitCount(); successPressed(impact); playSound(sound: "Bell-Tree", type: "mp3") },
                    //label: { Text("\(habitCount)") }
                    label: { Text("\((habits.first?.count ?? 0))") }
                )
                .buttonStyle(DynamicRoundButtonStyle())
                HStack {
                    Button(
                        //action: { moreOrLess = true },
                        action: { habits.first?.moreOrLess = true},
                        label: { Text("doMore") }
                    ).buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doMore, moreOrLess: true))
                    Button(
                        //action: { moreOrLess = false },
                        action: { habits.first?.moreOrLess = false},
                        label: { Text("doLess") }
                            )
                    .buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doLess, moreOrLess: false))
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

        
        // When the app loads
        .onAppear() {
            //print(habits)
            //print(habits.count)
            //print(habits.isEmpty)
            //print("onAppear Fired")
            
            // Check if this is the first time the app has been used
            if habits.count == 0
            {
                //print("First Use")
                // Create the first Habit entity in CoreData
                // UPDATE NOW: Replace this code with code that navigates to a view to setup the first habit
                addHabit(uuid: UUID(), creationDate: Date(), name: "placeholder", moreOrLess: moreOrLess, target: 0, count: 0)
                saveContext()
                // Need to debug this - we are reaching this code but the view isn't changing
                self.selection = "Welcome"
                //print("Welcome Fired")
                //addHabit(uuid: UUID(), creationDate: Date(), name: "placeholder1", moreOrLess: moreOrLess, target: 1, count: 1)
            }
            //print(habits.first?.name)
            
            // Check if it is a new day, and if so, setup the app for the new day
            if newDayDetector() {
                startNewDay()
            }
            
        }
        
        // When the app moves to the foreground
        .onReceive(NotificationCenter.default.publisher(for:
            UIApplication.willEnterForegroundNotification)) { _ in
            //print(habits)
            //print(habits.count)
            //print(habits.isEmpty)
            
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
    
    // Save habits to CoreData
    func saveContext() {
      do {
        try viewContext.save()
      } catch {
        print("Error saving managed object context: \(error)")
      }
    }
    
    // Add a new habit
    func addHabit(uuid: UUID, creationDate: Date, name: String, moreOrLess: Bool,  target: Int64, count: Int64) {
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
    func deleteHabit(at offsets: IndexSet) {
        // Go through the CoreData index to find and delete the specific habit
        offsets.forEach { index in
            let habit = self.habits[index]
            self.viewContext.delete(habit)
      }
      
        // Save the updated list of habits to CoreData
      saveContext()
    }
    
}



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




