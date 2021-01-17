//
//  PlaySound.swift
//  Simply Good Habits
//
//  Created by Paul on 1/17/21.
//

import AVFoundation

var audioPlayer: AVAudioPlayer?

// This function will play any mp3 loaded into the project
func playSound(sound: String, type: String) {
    if let path = Bundle.main.path(forResource: sound, ofType: type) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
            
        } catch {
        print("ERROR: Could not find and play that audio file")
            
        }
    }
}

// High-pitched peep
func playKeyPressedOne() {
    AudioServicesPlaySystemSound(1103)
    print("playKeyPressedOne")
}


// Normal tock sound
func playKeyPressedTwo() {
    AudioServicesPlaySystemSound(1104)
    print("playKeyPressedTwo")
}

// Normal tick sound
func playKeyPressedThree() {
    AudioServicesPlaySystemSound(1105)
    print("playKeyPressedThree")
}
