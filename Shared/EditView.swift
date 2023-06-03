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
//import NavigationStack

// Welcome View that shows the first time a user opens the app
struct EditView: View {
    @Binding var updateView: Bool
    // This managedObjectContext grants access to shared CoreData across views
    // But all of the data access functions have to be included in each view
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    
    // This will let me dismiss the view when the user hits the confirmation button
    //@EnvironmentObject var navStack: NavigationStack
    
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
    #if os(watchOS)
    @State var scrollAmount = 0.0
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Text("Edit Your Habit")
                        .font(.system(size: geometry.size.width * 0.12))
                        .underline()
                    Text("Target: \(abs(Int64(round((scrollAmount/10))))) ->")
                        .font(.system(size: geometry.size.width * 0.1))
                        .focusable(true)
                        .digitalCrownRotation($scrollAmount)
                    Button(
                        action: { moreOrLess = true; habitName = "Do More" },
                        label: { Text("Do More") }
                    )
                    .buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doMore, moreOrLess: moreOrLess))
                    Button(
                        action: { moreOrLess = false; habitName = "Do Less" },
                        label: { Text("Do Less") }
                    )
                    .buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doLess, moreOrLess: moreOrLess))
                    Button(
                        action: { target = String(abs(Int64(round((scrollAmount/10))))); fillInTheBlanks(); presentationMode.wrappedValue.dismiss() },
                        label: { Text("OK, Done!") }
                    )
                    .buttonStyle(SpecialButtonStyle(actionType: .confirm))
                }
                .padding(.horizontal, geometry.size.width * 0.05)
                .padding(.vertical, geometry.size.height * 0.05)
            }
            .onDisappear() {
                // Write the updated habit to CoreData
                if (habitName == originalHabitName) {
                    // If the name didn't change, keep the original UUID and creation date
                    CoreDataHelper.addHabit(context: viewContext, uuid: uuid, creationDate: creationDate, name: habitName, moreOrLess: moreOrLess, target: Int64(target) ?? 0, count: count)
                    print("original \(target)")
                } else {
                    // If the name changed, create a new UUID and creation date to mark the start of a new habit
                    CoreDataHelper.addHabit(context: viewContext, uuid: UUID(), creationDate: Date(), name: habitName, moreOrLess: moreOrLess, target: Int64(target) ?? 0, count: count)
                    print("new \(target)")
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
                scrollAmount = (Double(target) ?? 0) * 10
                
            }
        }
    }
    #else
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
                action: { fillInTheBlanks(); presentationMode.wrappedValue.dismiss() },
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
                CoreDataHelper.addHabit(context: viewContext, uuid: uuid, creationDate: creationDate, name: habitName, moreOrLess: moreOrLess, target: Int64(target) ?? 0, count: count)
            } else {
                // If the name changed, create a new UUID and creation date to mark the start of a new habit
                CoreDataHelper.addHabit(context: viewContext, uuid: UUID(), creationDate: Date(), name: habitName, moreOrLess: moreOrLess, target: Int64(target) ?? 0, count: count)
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
    #endif

    
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
        EditView(updateView: .constant(false))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


