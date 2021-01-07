//
//  CustomButtonStyles.swift
//  Simply Good Habits
//
//  Created by Paul Krakow on 12/30/20.
//

import SwiftUI

// Quick check for which platform we're building for - since they support different Color objects
#if os(iOS)
    typealias XColor = UIColor
#elseif os(OSX)
    typealias XColor = NSColor
#endif

struct DynamicRoundButtonStyle: ButtonStyle {
    var font: Font = .largeTitle
    var padding: CGFloat = 8
    var bgColor = Color.green
    var fgColor = Color.white
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 50, maxWidth: .infinity, minHeight: 50, maxHeight: .infinity)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .font(font)
            .padding(padding)
            .background(bgColor)
            .foregroundColor(fgColor)
            .clipShape(Circle())
            .padding(.horizontal, 20)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring())
    }
}

struct DoMoreDoLessUndoButtonStyle: ButtonStyle {
    enum Action {
        case doMore, doLess, undo
        var fgColor: Color {
            switch self {
            case .doMore:
                return Color(XColor.white)
            case .doLess:
                return Color(XColor.white)
            case .undo:
                return Color(XColor.white)
            }
        }
        
        var bgColor: Color {
            switch self {
            case .doMore:
                return Color(XColor.systemGreen)
            case .doLess:
                return Color(XColor.systemYellow)
            case .undo:
                return Color(XColor.systemGray)
            }
        }
        
        var image: Image {
            switch self {
            case .doMore:
                return Image(systemName: "plus.square.fill")
            case .doLess:
                return Image(systemName: "minus.square" )
            case .undo:
                return Image(systemName: "arrow.uturn.backward.circle")
            }
        }
        
        var doMoreImage: Image {
            switch self {
            case .doMore:
                return Image(systemName: "plus.square.fill")
            case .doLess:
                return Image(systemName: "minus.square" )
            case .undo:
                return Image(systemName: "arrow.uturn.backward.circle")
            }
        }
        
        var doLessImage: Image {
            switch self {
            case .doMore:
                return Image(systemName: "plus.square")
            case .doLess:
                return Image(systemName: "minus.square.fill" )
            case .undo:
                return Image(systemName: "arrow.uturn.backward.circle")
            }
        }
        
    }
    var actionType: Action
    var withImage: Bool = true
    var moreOrLess: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if withImage{
                //actionType.image
                if moreOrLess {
                    actionType.doMoreImage
                } else {
                    actionType.doLessImage
                }
            }
            configuration.label
        }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(actionType.bgColor)
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.black))
            )
            .foregroundColor(actionType.fgColor)
            .font(Font.bold(.body)())
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

/*
struct RoundButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: 100, height: 100)
            .foregroundColor(Color.black)
            .background(Color.red)
            .clipShape(Circle())
    }
}

struct FilledRoundedCornerButtonStyle: ButtonStyle {
    var font: Font = .title
    var padding: CGFloat = 8
    var bgColor = Color("AppPrimary")
    var fgColor = Color("AppSecondary")
    var cornerRadius: CGFloat = 8
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .font(font)
            .padding(padding)
            .background(bgColor)
            .foregroundColor(fgColor)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring())
    }
}

*/
 

struct SpecialButtonStyle: ButtonStyle {
    enum Action {
        case confirm, cancel, delete
        var bgColor: Color {
            switch self {
            case .confirm:
                return Color(XColor.systemGreen)
            case .cancel:
                return Color(XColor.systemRed)
            case .delete:
                return Color(XColor.systemRed)
            }
        }
        var fgColor: Color {
            if self == .cancel {
                return Color(XColor.black)
            } else {
                return Color.white
            }
        }
        
        var stroke: Color {
            if self == .cancel {
                return fgColor
            } else {
                return bgColor
            }
        }
        
        var image: Image {
            switch self {
            case .confirm:
                return Image(systemName: "checkmark.rectangle.fill")
            case .cancel:
                return Image(systemName: "clear.fill")
            case .delete:
                return Image(systemName: "trash")
            }
        }

    }
    var actionType: Action
    var withImage: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if withImage{
                actionType.image
            }
            configuration.label
        }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(actionType.bgColor)
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(actionType.stroke))
            )
            .foregroundColor(actionType.fgColor)
            .font(Font.bold(.body)())
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

