//
//  RSDColorRules.swift
//  Research
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#endif

public enum RSDControlState : UInt {
    case normal = 0, highlighted = 1, disabled = 2, selected = 4
    
    #if os(iOS) || os(tvOS)
    public init(controlState: UIControl.State) {
        self = RSDControlState(rawValue: controlState.rawValue) ?? .normal
    }
    
    public var controlState: UIControl.State {
        return UIControl.State(rawValue: self.rawValue)
    }
    #endif
}


/// The color rules object is a concrete implementation of the design rules used for a given version of the
/// SageResearch frameworks. A module can use this class as-is or override the class to enforce a set of rules
/// pinned to the tasks included within a module. This is important to allow a module to be validated against
/// a given UI/UX. The frameworks can later change to reflect new devices, OS changes, and design system
/// updates to incorporate the results of more design studies.
open class RSDColorRules  {
    
    /// The version for the color rules. If the design rules change with future versions of this framework,
    /// then the current version number should be rev'd as well and any changes to this rule set that are not
    /// additive include logic to return the previous rules associated with a previous version.
    open private(set) var version: Int

    /// The color palette for this color design.
    open var palette: RSDColorPalette! {
        get {
            return _palette
        }
        set {
            guard newValue != nil else { return }
            _palette = newValue
        }
    }
    private var _palette: RSDColorPalette
    
    public init(palette: RSDColorPalette, version: Int? = nil) {
        self._palette = palette
        self.version = version ?? palette.version ?? RSDColorMatrix.shared.currentVersion
    }
    
    
    /// MARK: Default colors
    
    /// The named category or style for a given color.
    public enum Style : String, Codable, CaseIterable {
        /// The color "white".
        case white
        /// The primary color for the application.
        case primary
        /// The secondary color for the application.
        case secondary
        /// The accent color for the application.
        case accent
        /// The color to use on screens and icons that indicate success.
        case successGreen
        /// The color to use on screens and icons that indicate an error or alert.
        case errorRed
        /// A custom color should be defined for a given screen or icon. For example, a picture that shows
        /// someone running outside would have a "sky blue" background color that is defined independantly
        /// of the branding colors used by an app.
        case custom
    }
    
    /// The default color to use for a given color style.
    /// - parameter style: The color style.
    /// - returns: The color mapping for that style.
    open func mapping(for style: Style) -> RSDColorMapping? {
        switch style {
        case .white:
            return self.palette.grayScale.mapping(for: .white)
        case .primary:
            return self.palette.primary
        case .secondary:
            return self.palette.secondary
        case .accent:
            return self.palette.accent
        case .successGreen:
            return self.palette.successGreen
        case .errorRed:
            return self.palette.errorRed
        case .custom:
            return nil
        }
    }
    
    /// Look in the palette for a mapping for the given color. This method is used to allow returning a color
    /// mapping from a background color.
    ///
    /// - note: The primary use-case for this is where an app defines a view controller in a storyboard and
    /// uses @IBDesignable to render the screen in the storyboard. This allows setting colors by using the
    /// defaults and getting the color mapping from the background.
    ///
    /// - parameter style: The color (UIColor or NSColor) that maps to one of the colors defined in the palette.
    /// - returns: The color mapping if found.
    open func mapping(for color: RSDColor) -> RSDColorMapping? {
        let families: [RSDColorFamily] = [_palette.grayScale, _palette.primary.swatch, _palette.secondary.swatch, _palette.accent.swatch, _palette.successGreen.swatch, _palette.errorRed.swatch]
        for family in families {
            if let mapping = family.mapping(for: color) {
                return mapping
            }
        }
        return nil
    }

        
    /// Background color for views that should have a light background.
    ///
    /// - Default: `white`
    open var backgroundLight: RSDColorTile {
        return self.palette.grayScale.white
    }
    
    /// Background color for views that should use the primary color tile for the background.
    ///
    /// - Default: `primary`
    open var backgroundPrimary: RSDColorTile {
        return self.palette.primary.normal
    }
    
    /// Tinted image icon color on a given background. Typically, this is used in a collection or table view.
    ///
    /// - Default:
    ///     If the background uses light style
    ///         then `white`
    ///         else `accent`
    open func tintedIconColor(on background: RSDColorTile) -> RSDColor {
        if background.usesLightStyle {
            return self.palette.grayScale.white.color
        }
        else {
            return self.palette.accent.normal.color
        }
    }

    /// Color for text throughout the app.
    ///
    /// - Default:
    ///     If the background uses light style
    ///         then `white`
    ///         else `veryDarkGray`
    ///
    /// - parameters:
    ///     - background: The background of the text UI element.
    ///     - textType: The type size of the UI element.
    /// - returns: The text color to use.
    open func textColor(on background: RSDColorTile, for textType: RSDDesignSystem.TextType) -> RSDColor {
        if background.usesLightStyle {
            return self.palette.grayScale.white.color
        }
        else {
            return self.palette.grayScale.veryDarkGray.color
        }
    }
    
    
    /// MARK: Buttons
    
    /// Tinted button color on a given background.
    ///
    /// - Default:
    ///     If the background uses light style then `white`
    ///     else if the background is the primary palette color then `secondary`
    ///     else `veryDarkGray`
    ///
    /// - parameters:
    ///     - background: The background of the text UI element.
    /// - returns: The color to use for tinted buttons.
    open func tintedButtonColor(on background: RSDColorTile) -> RSDColor {
        if background.usesLightStyle {
            return self.palette.grayScale.white.color
        }
        else if background == self.palette.primary.normal ||
            background == self.palette.grayScale.white ||
            background == self.palette.grayScale.veryLightGray {
            return self.palette.secondary.normal.color
        }
        else {
            return self.palette.grayScale.veryDarkGray.color
        }
    }
    
    /// Underlined text button.
    ///
    /// - Default:
    ///     If the background is `white` or `veryLightGray`
    ///         then if the primary color uses light style return `primary`
    ///         else `tinted button color`
    ///     else `text color`
    ///
    /// - parameters:
    ///     - background: The background of the text button.
    ///     - state: The UI control state of the button.
    /// - returns: The color to use for the underlined text button.
    open func underlinedTextButton(on background: RSDColorTile, state: RSDControlState) -> RSDColor {
        if background == self.palette.grayScale.white || background == self.palette.grayScale.veryLightGray {
            if self.palette.primary.normal.usesLightStyle {
                return self.palette.primary.normal.color
            }
            else {
                return self.tintedButtonColor(on: background)
            }
        }
        else {
            return textColor(on: background, for: .body)
        }
    }
    
    /// The color mapping to use on a given background for a given button type.
    ///
    /// - Default:
    ///     If the background is `white` and the button type is `primary`
    ///         then `secondary` color
    ///         else `veryLightGray` color
    ///
    /// - parameters:
    ///     - background: The background of the button.
    ///     - buttonType: The type of button (primary or secondary).
    /// - returns: The color mapping to use for a rounded button.
    open func roundedButton(on background: RSDColorTile, buttonType: RSDDesignSystem.ButtonType) -> RSDColorMapping {
        if background == self.palette.grayScale.white && buttonType == .primary {
            return self.palette.secondary
        }
        else {
            return self.palette.grayScale.mapping(for: .veryLightGray)
        }
    }
    
    /// The color for a rounded button for a given state and button type.
    ///
    /// - parameters:
    ///     - background: The background of the button.
    ///     - buttonType: The type of button (primary or secondary).
    ///     - state: The UI control state of the button.
    /// - returns: The color to use for the background of a rounded button.
    open func roundedButton(on background: RSDColorTile, with buttonType: RSDDesignSystem.ButtonType, forState state: RSDControlState) -> RSDColor {
        let tile = self.roundedButton(on: background, buttonType: buttonType)
        switch state {
        case .highlighted:
            if tile.index > 0, tile.colorTiles[tile.index - 1] != background {
                return tile.colorTiles[tile.index - 1].color
            }
            else if tile.index + 1 < tile.colorTiles.count {
                return tile.colorTiles[tile.index + 1].color
            }
            else {
                return tile.normal.color
            }
            
        case .disabled:
            return tile.normal.color.withAlphaComponent(0.35)
            
        default:
            return tile.normal.color
        }
    }
    
    /// The text color for a rounded button.
    ///
    /// - parameters:
    ///     - background: The background of the button.
    ///     - buttonType: The type of button (primary or secondary).
    ///     - state: The UI control state of the button.
    /// - returns: The color to use for the text of a rounded button.
    open func roundedButtonText(on background: RSDColorTile, with buttonType: RSDDesignSystem.ButtonType, forState state: RSDControlState) -> RSDColor {
        let tile = self.roundedButton(on: background, buttonType: buttonType)
        let color = textColor(on: tile.normal, for: .heading4)
        if state == .disabled && !tile.normal.usesLightStyle {
            return color.withAlphaComponent(0.35)
        }
        else {
            return color
        }
    }
    
    /// Checkboxes button.
    ///
    /// - parameters:
    ///     - background: The background of the checkbox.
    ///     - isSelected: Whether or not the checkbox is selected.
    /// - returns:
    ///     - checkmark: The checkmark color.
    //      - background: The background (fill) color.
    //      - border: The border color.
    open func checkboxButton(on background: RSDColorTile, isSelected: Bool) ->
        (checkmark: RSDColor, background: RSDColor, border: RSDColor) {
            
            let inner: RSDColorTile
            let border: RSDColor
            
            if background == self.palette.grayScale.white {
                inner = isSelected ? self.palette.primary.dark : self.palette.grayScale.white
                border = isSelected ? self.palette.primary.normal.color : self.palette.grayScale.veryLightGray.color
            }
            else {
                inner = isSelected ? self.palette.secondary.normal : self.palette.grayScale.white
                border = isSelected ? self.palette.secondary.light.color : self.palette.grayScale.veryLightGray.color
            }
            
            let check = isSelected
                ? (inner.usesLightStyle ?  self.palette.grayScale.white.color : self.palette.grayScale.veryDarkGray.color)
                : RSDColor.clear
            
            return (check, inner.color, border)
    }
    
    
    /// MARK: Progress indicator colors
    
    /// The colors to use with a progress bar.
    ///
    /// - parameter background: The background for the progress bar.
    /// - returns:
    ///     - filled: The fill color for the progress bar which marks progress.
    ///     - unfilled: The unfilled (background) color for the progress bar.
    open func progressBar(on background: RSDColorTile) -> (filled: RSDColor, unfilled: RSDColor) {
        return (self.palette.accent.light.color, self.palette.grayScale.veryLightGray.color)
    }
    
    /// The colors to use with a progress dial.
    ///
    /// - parameters:
    ///     - background: The background color tile for the view that this view "lives" in.
    ///     - style: The style of the dial. If non-nil, this will be used as the color of the inner circle.
    ///     - innerColor: The inner color of the dial set by the nib or storyboard.
    ///     - usesLightStyle: The light-style set by the nib or storyboard.
    /// - returns:
    ///     - filled: The fill color for the progress bar which marks progress.
    ///     - unfilled: The unfilled (background) color for the progress bar.
    ///     - inner: The inner color to use for the progress bar.
    open func progressDial(on background: RSDColorTile, style: Style?,
                           innerColor: RSDColor = RSDColor.clear,
                           usesLightStyle: Bool = false) -> (filled: RSDColor, unfilled: RSDColor, inner: RSDColorTile) {
        if let style = style, let mapping = self.mapping(for: style) {
            return (mapping.light.color, self.palette.grayScale.veryLightGray.color, mapping.normal)
        }
        else if let mapping = mapping(for: innerColor) {
            return (mapping.light.color, self.palette.grayScale.veryLightGray.color, mapping.normal)
        }
        else {
            let filled = self.palette.accent.light.color
            let unfilled = self.palette.grayScale.veryLightGray.color
            let lightStyle = (innerColor == RSDColor.clear) ? background.usesLightStyle : usesLightStyle
            let inner = RSDColorTile(innerColor, usesLightStyle: lightStyle)
            return (filled, unfilled, inner)
        }
    }

    
    /// MARK: Completion
    
    /// Rounded checkmarks are drawn UI elements of a checkmark with a solid background.
    ///
    /// - parameter background: The background of the checkbox.
    /// - returns:
    ///     - checkmark: The checkmark color.
    //      - background: The background (fill) color.
    //      - border: The border color.
    open func roundedCheckmark(on background: RSDColorTile) -> (checkmark: RSDColor, background: RSDColor, border: RSDColor) {
        return (self.palette.grayScale.white.color,
                self.palette.secondary.normal.color,
                self.palette.secondary.normal.color)
    }
    
    /// For a completion gradient background, what are the min and max colors?
    /// - returns:
    ///     - 0: The min color tile.
    ///     - 1: The max color tile.
    open func completionGradient() -> (RSDColorTile, RSDColorTile) {
        return (self.palette.successGreen.light, self.palette.successGreen.normal)
    }
    
    /// MARK: Choice Selection cell
    
    /// The background color tile for the table cell.
    /// - parameters:
    ///     - background: The background of the table.
    ///     - isSelected: Whether or not the cell is selected.
    /// - returns: The color tile for the background of the cell.
    open func tableCellBackground(on background: RSDColorTile, isSelected: Bool) -> RSDColorTile {
        return isSelected ?  self.palette.primary.colorTiles.first! : self.palette.grayScale.white
    }
    
    /// The background color tile for the table cell.
    /// - parameter background: The background of the table.
    /// - returns: The color tile for the background of the section header.
    open func tableSectionBackground(on background: RSDColorTile) -> RSDColorTile {
        return self.palette.grayScale.white
    }

    /// The cell separator line for a table cell or other border.
    open var separatorLine: RSDColor {
        return self.palette.grayScale.veryLightGray.color
    }
    
    /// The color of an underline for a text field.
    /// - parameter background: The background of the table cell.
    /// - returns: The color of the underline.
    open func textFieldUnderline(on background: RSDColorTile) -> RSDColor {
        return background.usesLightStyle ? self.palette.grayScale.white.color : self.palette.grayScale.darkGray.color
    }
}
