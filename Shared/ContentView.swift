//
//  ContentView.swift
//  Shared
//
//  Created by Paul Krakow on 12/28/20.
//

// TODO Notes
// The app is locked in portrait mode because there were issues with landscape mode


import SwiftUI
import CoreData
//import NavigationStack
import WatchConnectivity


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selection: String? = nil
    @State private var updateView: Bool = false
    @State private var isWelcomeViewPresented: Bool = false
    @State private var isEditingViewPresented: Bool = false
    @StateObject private var buttonColorObservable = BackgroundColorObservable(bgColor: Color.gray)
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    
    // Retrieve stored habits from CoreData
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [
            // Note that the sort order is in place to make it easy to grab the latest entry in CoreData
            // Do not change this
            NSSortDescriptor(keyPath: \Habit.creationDate, ascending: false)
        ]
    ) var habits: FetchedResults<Habit>
    
    #if os(watchOS)
    // watchOS version of ContentView
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Text(habits.first?.name ?? "First Good Habit")
                        .foregroundColor(Color.blue)
                        .onTapGesture {
                            isEditingViewPresented = true
                        }
                        .sheet(isPresented: $isWelcomeViewPresented) {
                            WelcomeView(updateView: $updateView, isPresented: $isWelcomeViewPresented)
                        }
                        .sheet(isPresented: $isEditingViewPresented) {
                            EditView(updateView: $updateView)
                        }

                    Button(
                        action: { incrementHabitCount() },
                        label: { Text("\((habits.first?.moreOrLess ?? true ? String("\((habits.first?.count ?? 0))") : String("\((habits.first?.target ?? 0) - (habits.first?.count ?? 0))") ))") }  // Advanced version that counts down for doLess
                    )
                    //.buttonStyle(DynamicRoundButtonStyle(bgColor: updateButtonColor()))
                    .buttonStyle(DynamicRoundButtonStyle(bgColorObservable: buttonColorObservable))
                    .shadow(color: .dropShadow, radius: 2, x: 2, y: 2)
                    .shadow(color: .dropLight, radius: 2, x: -2, y: -2)
                    .scaledToFill()

                    Button(
                        action: { decrementHabitCount() },
                        label: { Text("Undo") }
                    )
                    .font(.footnote)
                }
                .padding(.top, geometry.safeAreaInsets.top + 20) // Increase the top padding
                .offset(y: 20) // Increase the y-axis offset
                .frame(width: geometry.size.width, height: geometry.size.height)
                .edgesIgnoringSafeArea(.all)
            }
        }
        .environment(\.managedObjectContext, viewContext)
        // When the app loads
        .onAppear() {
            // Check if this is the first time the app has been used
            if habits.count == 0 {
                print("First Use")
                // Create the first Habit entity in CoreData
                // Navigate to the WelcomeView to let the user set up the first good habit
                self.isWelcomeViewPresented = true
            }
            
            // Check if it is a new day, and if so, setup the app for the new day
            if newDayDetector() {
                startNewDay()
            }
        }
        // When the WatchOS app moves to the foreground
        .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationDidBecomeActiveNotification)) { _ in
            // Check if it is a new day, and if so, setup the app for the new day
            if newDayDetector() {
                startNewDay()
            }
        }
    }
    
    #else
    // iOS version of ContentView
    var body: some View {
        NavigationView {
            VStack {
                Text("Simply Good Habits")
                    .font(.largeTitle)
                    .underline()
                Text(habits.first?.name ?? "First Good Habit").foregroundColor(Color.blue)
                    .onTapGesture {
                        selection = "Edit"
                    }
                    .sheet(isPresented: $isWelcomeViewPresented) {
                WelcomeView(updateView: $updateView, isPresented: $isWelcomeViewPresented)
            }
                Button(
                    action: { incrementHabitCount(); successPressed(impact); playSound(sound: "Bell-Tree", type: "mp3") },
                    label: { Text("\((habits.first?.moreOrLess ?? true ? String("\((habits.first?.count ?? 0))") : String("\((habits.first?.target ?? 0) - (habits.first?.count ?? 0))") ))") }  // Advanced version that counts down for doLess
                )
                //.buttonStyle(DynamicRoundButtonStyle(bgColor: updateButtonColor()))
                .buttonStyle(DynamicRoundButtonStyle(bgColorObservable: buttonColorObservable))
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
            .onChange(of: habits.first?.count) { _ in
                buttonColorObservable.bgColor = updateButtonColor()
            }
        }
        .environment(\.managedObjectContext, viewContext)
        // When the app loads
        .onAppear() {
            //print("onAppear Fired")
            
            // Check if this is the first time the app has been used
            if !hasLaunchedBefore && habits.count == 0 {
                print("First Use")
                // Create the first Habit entity in CoreData
                // Navigate to the WelcomeView to let the user set up the first good habit
                self.isWelcomeViewPresented = true
                hasLaunchedBefore = true
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
    #endif
    
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
        CoreDataHelper.addHabit(context: viewContext, uuid: (habits.first?.uuid)!, creationDate: Date(), name: (habits.first?.name)!, moreOrLess: (habits.first?.moreOrLess)!, target: (habits.first?.target)!, count: 0)
        CoreDataHelper.saveContext(context: viewContext)
    }
    
    // Increase the habit count by 1
    func incrementHabitCount() -> Void {
        print("incrementHabitCount Called")
        habits.first?.count += 1
        CoreDataHelper.saveContext(context: viewContext)
        buttonColorObservable.bgColor = updateButtonColor()
    }
    
    // Decrease the habit count by 1
    func decrementHabitCount() -> Void {
        print("decrementHabitCountCalled")
        if habits.first?.count ?? 0 > 0 {
            habits.first?.count -= 1
            CoreDataHelper.saveContext(context: viewContext)
            buttonColorObservable.bgColor = updateButtonColor()
        }
    }
    
    // Change the button color to reflect how the habit.count relates to the habit.target
    func updateButtonColor() -> Color {
        print("updateButtonColor Called")
        let updateCount = Double(habits.first?.count ?? 0)
        print("updateCount = ", updateCount)
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
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext,
            PersistenceController.preview.container.viewContext)
    }
}
