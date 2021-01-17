//
//  Haptics.swift
//  Simply Good Habits
//
//  Created by Paul on 1/17/21.
//

import UIKit

let impact = UIImpactFeedbackGenerator() // 1

func impactPressed(_ sender: Any) {
    impact.impactOccurred() // 2
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

