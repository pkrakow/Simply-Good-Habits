//
//  ContentView.swift
//  Shared
//
//  Created by Paul Krakow on 12/28/20.
//

import SwiftUI

struct ContentView: View {
    
    @State var habitCount = 0
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
        habitCount += 1
        //print("habitCount \(habitCount)")
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




