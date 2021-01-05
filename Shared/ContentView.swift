//
//  ContentView.swift
//  Shared
//
//  Created by Paul Krakow on 12/28/20.
//

import SwiftUI

struct ContentView: View {
    
    @State var habitCount = 0
    @State var yesterdayHabitCount = 0
    @State var habitDictionary = [Date:Int]()
    let habitTarget = 5
    
    var body: some View {
        VStack {
            Text("Simply Good Habits")
                .font(.largeTitle)
            Button(
                action: { incrementHabitCount() },
                label: { Text("\(habitCount)") }
            )
            .buttonStyle(DynamicRoundButtonStyle())
        }
    }
    
    func incrementHabitCount() -> Void {
        // Lookup what year, month and day it is right now
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        
        // Lookup the latest entry in the habitDictionary
        let latestHabitDictionaryEntry = habitDictionary.max { a, b in a.key < b.key }
        let dayOfLastEntry = formatter.string(from: latestHabitDictionaryEntry?.key ?? Date())
        
        // Check if it was from a day other than today
        if dayOfLastEntry != today {
            habitCount = 1
        } else {
            habitCount += 1
        }
        habitDictionary[Date()] = 1
        //print("habitCount \(habitCount)")
        //print("habitDictionary: \(habitDictionary)")
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
        ContentView()
    }
}




