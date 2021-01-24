//
//  WelcomeView.swift
//  Simply Good Habits
//
//  Created by Paul on 1/23/21.
//
// https://www.simpleswiftguide.com/swiftui-form-tutorial-how-to-create-and-use-form-in-swiftui/


import SwiftUI
import CoreData

// Welcome View that shows the first time a user opens the app
struct WelcomeView: View {
    @State var dummy: String = ""
    
    // Retrieve stored habits from CoreData
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [
            // Note that the sort order is in place to make it easy to grab the latest entry in CoreData
            // Do not change this
            NSSortDescriptor(keyPath: \Habit.creationDate, ascending: false)
        ]
    ) var habits: FetchedResults<Habit>
    
    
    // UPDATE LATER: I can access the CoreData object, but haven't figured out how to access the related funcs
    // Researching how to do that now - then I need to update this view to populate the first habit
    // and then navigate to the main view

    var body: some View {
        VStack {
            Text("Simply Good Habits")
                .font(.largeTitle)
                .underline()
                .padding()
            Text("Welcome to a simple app that helps you build good daily habits.")
            Text("To get started, please fill out this little survey on the habit you would like to work on:")
           
            Form {
                TextField("Habit \((habits.first?.count ?? 0))", text: $dummy)
            }
        }
        /*
        // UPDATE SOON:
        // Test code to see if I can get the CoreData functions in one file to work in another file
        // I may need to build a dedicated app to figure out how to get something like this to work
        .onAppear() {
            addHabit(uuid: UUID(), creationDate: Date(), name: "placeholder", moreOrLess: moreOrLess, target: 0, count: 0)
            saveContext()
        }
        */
    }
}
