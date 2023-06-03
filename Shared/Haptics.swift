//
//  Haptics.swift
//  Simply Good Habits
//
//  Created by Paul on 1/17/21.
//

import Foundation

#if canImport(UIKit)
import UIKit

let impact = UIImpactFeedbackGenerator()

func impactPressed(_ sender: Any) {
    impact.impactOccurred()
}

let selection = UISelectionFeedbackGenerator()

func selectionPressed(_ sender: Any) {
    selection.selectionChanged()
}

let notification = UINotificationFeedbackGenerator()

func successPressed(_ sender: Any) {
    notification.notificationOccurred(.success)
}

func warningPressed(_ sender: Any) {
    notification.notificationOccurred(.warning)
}

func errorPressed(_ sender: Any) {
    notification.notificationOccurred(.error)
}
#else
// Provide empty implementations for macOS
func impactPressed(_ sender: Any) { }
func selectionPressed(_ sender: Any) { }
func successPressed(_ sender: Any) { }
func warningPressed(_ sender: Any) { }
func errorPressed(_ sender: Any) { }
#endif
