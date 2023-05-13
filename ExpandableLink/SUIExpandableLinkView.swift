//
//  SUIExpandableLinkView.swift
//  CCLStyles
//
//  Created by Alan Zúñiga on 21/04/23.
//  Copyright © 2023 Carnival Corporation. All rights reserved.
//

import SwiftUI

// MARK: View
/// Figma link:
/// https://www.figma.com/file/sMSSHshbQELLhtaPLreNkQ/HUBAPP---Design-System?node-id=317-789&t=007hVS8kW3hb4K0Z-0
///
public struct SUIExpandableLinkView: View {
    // MARK: State
    @Binding var isExpanded: Bool

    // MARK: Properties
    var texts: (collapsed: String, expanded: String)
    var scheme: SUIExpandableLinkViewScheme

    // MARK: Initializers
    ///
    /// - Parameters:
    ///   - texts: Tuple containing texts for collapsed and expanded states
    ///   - isExpanded: Binding for expanded state
    ///   - scheme: Style scheme for componenttyle scheme for component
    ///
    public init(
        _ texts: (collapsed: String, expanded: String) = (
            "SUIExpandableLink.Label.Collapsed".localized,
            "SUIExpandableLink.Label.Expanded".localized
        ),
        isExpanded: Binding<Bool>,
        scheme: SUIExpandableLinkViewScheme = .init()
    ) {
        self._isExpanded = isExpanded
        self.texts = texts
        self.scheme = scheme
    }

    // MARK: Body
    public var body: some View {
        HStack(spacing: scheme.spacing) {
            Text(getLabel())
                .cclFont(
                    name: scheme.textFont,
                    size: scheme.textSize,
                    color: UIColor(scheme.textColor)
                )
            Image(scheme.iconName, bundle: scheme.iconBundle)
                .foregroundColor(scheme.iconColor)
                .rotationEffect(isExpanded ? Constants.expandedRotation : Constants.collapsedRotation)
        }
        .frame(minHeight: Constants.ADAMinHeight)
        .onTapGesture {
            isExpanded.toggle()
        }
        .animation(scheme.animation, value: isExpanded)
    }

    private func getLabel() -> String {
        isExpanded ? texts.expanded : texts.collapsed
    }

    private struct Constants {
        static let ADAMinHeight: Double = 44.0
        static let expandedRotation: Angle = .degrees(-180)
        static let collapsedRotation: Angle = .degrees(0)
    }
}

// MARK: Style Scheme
public struct SUIExpandableLinkViewScheme {

    // Style
    public var animation: Animation
    public var spacing: Double

    // Icon style
    public var iconBundle: Bundle
    public var iconColor: Color
    public var iconName: String

    // Text style
    public var textColor: Color
    public var textFont: CCLFont
    public var textSize: Double

    public init(
        animation: Animation = .linear,
        spacing: Double = 8.0,
        iconBundle: Bundle? = nil,
        iconColor: Color = .SUICarnivalBlue,
        iconName: String = "dropdown",
        textColor: Color = .SUICarnivalBlue,
        textFont: CCLFont = .helveticaNeueBold,
        textSize: Double = 14.0
    ) {
        self.animation = animation
        self.spacing = spacing
        self.iconBundle = iconBundle ?? .CCLStyles
        self.iconColor = iconColor
        self.iconName = iconName
        self.textColor = textColor
        self.textFont = textFont
        self.textSize = textSize
    }
}

// MARK: Previews
struct SUIExpandableLinkView_Previews: PreviewProvider {
    static var previews: some View {
        SUIExpandableLinkViewTest()
    }

    struct SUIExpandableLinkViewTest: View {
        @State var isExpanded: Bool = false
        var body: some View {
            VStack(spacing: 16) {
                SUIExpandableLinkView(isExpanded: $isExpanded)
            }
        }
    }
}
