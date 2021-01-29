//
//  WelcomeView.swift
//  Simply Good Habits
//
//  Created by Paul on 1/23/21.
//
// https://www.simpleswiftguide.com/swiftui-form-tutorial-how-to-create-and-use-form-in-swiftui/
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-a-view-dismiss-itself

import SwiftUI
import CoreData
import Combine

// Welcome View that shows the first time a user opens the app
struct WelcomeView: View {
    // This managedObjectContext grants access to shared CoreData across views
    // But all of the data access functions have to be included in each view
    @Environment(\.managedObjectContext) private var viewContext
    
    // This will let me dismiss the view when the user hits the confirmation button
    @Environment(\.presentationMode) var presentationMode
    
    // Variables to hold the data collected in the form
    @State var habitName: String = ""
    @State var target: String = ""
    @State var moreOrLess: Bool = true
    
    // Retrieve stored habits from CoreData
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [
            // Note that the sort order is in place to make it easy to grab the latest entry in CoreData
            // Do not change this
            NSSortDescriptor(keyPath: \Habit.creationDate, ascending: false)
        ]
    ) var habits: FetchedResults<Habit>
    
    // The WelcomeView objects
    var body: some View {
        VStack {
            Text("Simply Good Habits")
                .font(.largeTitle)
                .underline()
                .padding()
            Text("We'd like to help you build good habits. To get started, please fill out this little survey:")
            Spacer()
            TextField("What is your first good habit?", text: $habitName)
                .font(.title)
            TextField("What's your daily target?", text: $target)
                .keyboardType(.numberPad)
                .onReceive(Just(target)) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        self.target = filtered
                    }
                }
                .font(.title)

            VStack {
                Text("Do you want to work on doing things...")
                    .foregroundColor(.gray)
                    .font(.title)
                HStack {
                    Button(
                        action: { moreOrLess = true},
                        label: { Text("...more often") }
                    ).buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doMore, moreOrLess: moreOrLess))
                    Button(
                        action: { moreOrLess = false},
                        label: { Text("...less often") }
                            )
                    .buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doLess, moreOrLess: moreOrLess))
                    Spacer()
                }.padding()
            }
            Spacer()

            Button(
                action: { fillInTheBlanks(); self.presentationMode.wrappedValue.dismiss() },
                label: { Text("Start building good habits") }
            )
            .buttonStyle(SpecialButtonStyle(actionType: .confirm))
            Spacer()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        // When the view is dismissed, write the first Habit into CoreData
        .onDisappear() {
            if habits.count == 0 {
                addHabit(uuid: UUID(), creationDate: Date(), name: habitName, moreOrLess: moreOrLess, target: Int64(target) ?? 0, count: 0)
            }
        }
    }
    
    // Save habits to CoreData - duplicate of the ContentView func
    public func saveContext() {
      do {
        try viewContext.save()
      } catch {
        print("Error saving managed object context: \(error)")
      }
    }
    
    // Add a new habit - duplicate of the ContentView func
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
    
    // Set default values for the first habit if the user does not enter them
    func fillInTheBlanks() {
        if habitName == "" {
            habitName = "First Good Habit"
        }
        if (target == "" && moreOrLess) {
            target = "5"
        }
        if (target == "" && !moreOrLess) {
            target = "0"
        }
    }
    
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView().environment(\.managedObjectContext,
            PersistenceController.preview.container.viewContext)
    }
}
