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
    @Binding var updateView: Bool
    @Binding var isPresented: Bool
    
    // This managedObjectContext grants access to shared CoreData across views
    // But all of the data access functions have to be included in each view
    @Environment(\.managedObjectContext) private var viewContext
    
    // This will let me dismiss the view when the user hits the confirmation button
    // Temporarily commented out because Xcode threw an error after I updated to version 14.2
    //@EnvironmentObject var navStack: NavigationStack
    
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
    #if os(watchOS)
    @State var scrollAmount = 0.0
    var body: some View {
        NavigationView {
            VStack {
                Text("Your First Habit")
                    .underline()
                Text("Target: \(abs(Int64(round((scrollAmount/10))))) ->")
                    .focusable(true)
                    .digitalCrownRotation($scrollAmount)
                Button(
                    action: { moreOrLess = true; habitName = "Do More" },
                    label: { Text("Do More") }
                ).buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doMore, moreOrLess: moreOrLess))
                Button(
                    action: { moreOrLess = false; habitName = "Do Less" },
                    label: { Text("Do Less") }
                )
                .buttonStyle(DoMoreDoLessUndoButtonStyle(actionType: .doLess, moreOrLess: moreOrLess))
                Button(action: {
                    target = String(abs(Int64(round((scrollAmount/10)))));
                    fillInTheBlanks();
                    self.isPresented = false
                    self.updateView = true
                    
                    // Add the habit and then navigate
                    CoreDataHelper.addHabit(context: viewContext, uuid: UUID(), creationDate: Date(), name: habitName, moreOrLess: moreOrLess, target: Int64(target) ?? 0, count: 0)
                    print("[WatchOS] Habit added.")  // debug
                    
                }) {
                    Text("Get Started")
                }
                .buttonStyle(SpecialButtonStyle(actionType: .confirm))
            }
            // When the view is dismissed, write the first Habit into CoreData
            .onDisappear() {
                if habits.count == 0 {
                    print("[WatchOS] Adding habit...")  // debug
                    CoreDataHelper.addHabit(context: viewContext, uuid: UUID(), creationDate: Date(), name: habitName, moreOrLess: moreOrLess, target: Int64(target) ?? 0, count: 0)
                    print("[WatchOS] Habit added.")  // debug
                }
                /*
                if habits.count == 0 {
                    CoreDataHelper.addHabit(context: viewContext, uuid: (habits.first?.uuid)!, creationDate: Date(), name: (habits.first?.name)!, moreOrLess: (habits.first?.moreOrLess)!, target: (habits.first?.target)!, count: 0)
                }
                */

            }
        }
    }
    #else
    var body: some View {
        VStack {
            Text("Simply Good Habits")
                .font(.largeTitle)
                .underline()
            Text("To get started, please fill out this little survey:")
            Spacer()
            HStack {
                Text("Name:")
                TextField("What do you want to do?", text: $habitName)
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
                action: {
                    fillInTheBlanks();
                    self.isPresented = false
                    self.updateView = true
                },
                label: { Text("Start building good habits") }
            )
            .buttonStyle(SpecialButtonStyle(actionType: .confirm))
            Spacer()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        // When the view is dismissed, write the first Habit into CoreData
        /*
         .onDisappear() {
            //print("Testing if we get here on an iPad 2")
            if habits.count == 0 {
                //print("Testing if we get here on an iPad 3")
                CoreDataHelper.addHabit(context: viewContext, uuid: (habits.first?.uuid)!, creationDate: Date(), name: (habits.first?.name)!, moreOrLess: (habits.first?.moreOrLess)!, target: (habits.first?.target)!, count: 0)
            }
        }
         */
        .onDisappear() {
            if habits.count == 0 {
                print("[iOS] Adding habit...")  // debug
                CoreDataHelper.addHabit(context: viewContext, uuid: UUID(), creationDate: Date(), name: habitName, moreOrLess: moreOrLess, target: Int64(target) ?? 0, count: 0)
                print("[iOS] Habit added.")  // debug
            }
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

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(updateView: .constant(false), isPresented: .constant(false)).environment(\.managedObjectContext,
            PersistenceController.preview.container.viewContext)
    }
}

