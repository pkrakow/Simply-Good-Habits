//
//  EditView.swift
//  Simply Good Habits
//
//  Created by Paul on 2/1/21.
//
// https://www.simpleswiftguide.com/swiftui-form-tutorial-how-to-create-and-use-form-in-swiftui/
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-a-view-dismiss-itself

import SwiftUI
import CoreData
import Combine

// Welcome View that shows the first time a user opens the app
struct EditView: View {
    // This managedObjectContext grants access to shared CoreData across views
    // But all of the data access functions have to be included in each view
    @Environment(\.managedObjectContext) private var viewContext
    
    // This will let me dismiss the view when the user hits the confirmation button
    @Environment(\.presentationMode) var presentationMode
    
    // Variables to hold the data collected in the form
    @State var uuid: UUID = UUID()
    @State var creationDate: Date = Date()
    @State var habitName: String = ""
    @State var originalHabitName: String = ""
    @State var moreOrLess: Bool = true
    @State var target: String = ""
    @State var count: Int64 = 0

    
    // Retrieve stored habits from CoreData
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [
            // Note that the sort order is in place to make it easy to grab the latest entry in CoreData
            // Do not change this
            NSSortDescriptor(keyPath: \Habit.creationDate, ascending: false)
        ]
    ) var habits: FetchedResults<Habit>
    
    // The EditView objects
    var body: some View {
        VStack {
            Text("Simply Good Habits")
                .font(.largeTitle)
                .underline()
            Text("Edit your good habit here:")
            Spacer()
            HStack {
                Text("Name:")
                TextField("What is your good habit?", text: $habitName)
            }
            .padding()

            HStack {
                Text("Target:")
                TextField("What's your daily target?", text: $target)
                    .keyboardType(.numberPad)
                    .onReceive(Just(target)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.target = filtered
                    }
                }
            }
            .padding()

            VStack {
                Text("Do this:")

                HStack {
                    Button(
                        action: { moreOrLess = true},
                        label: { Text("More Often") }
                    ).buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doMore, moreOrLess: moreOrLess))
                    Button(
                        action: { moreOrLess = false},
                        label: { Text("Less Often") }
                    )
                    .buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doLess, moreOrLess: moreOrLess))
                }
            }
            .padding()
            Spacer()
            Button(
                action: { fillInTheBlanks(); self.presentationMode.wrappedValue.dismiss() },
                label: { Text("Go back to building good habits") }
            )
            .buttonStyle(SpecialButtonStyle(actionType: .confirm))
            Spacer()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        // When the view is dismissed, write the first Habit into CoreData
        .onDisappear() {
            // Write the updated habit to CoreData
            if (habitName == originalHabitName) {
                // If the name didn't change, keep the original UUID and creation date
                addHabit(uuid: uuid, creationDate: creationDate, name: habitName, moreOrLess: moreOrLess, target: Int64(target) ?? 0, count: count)
            } else {
                // If the name changed, create a new UUID and creation date to mark the start of a new habit
                addHabit(uuid: UUID(), creationDate: Date(), name: habitName, moreOrLess: moreOrLess, target: Int64(target) ?? 0, count: count)
            }
        }
        .onAppear() {
            uuid = habits.first?.uuid ?? UUID()
            creationDate = habits.first?.creationDate ?? Date()
            habitName = habits.first?.name ?? ""
            originalHabitName = habitName
            moreOrLess = habits.first?.moreOrLess ?? true
            target = String(habits.first?.target ?? 0)
            count = habits.first?.count ?? 0
            fillInTheBlanks()
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

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView().environment(\.managedObjectContext,
            PersistenceController.preview.container.viewContext)
    }
}

