//
//  RSDTableViewCell.swift
//  ResearchUI (iOS)
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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

internal let kTableSideMargin: CGFloat = 28.0
internal let kTableSeparatorInsetMargin: CGFloat = 0.0
internal let kTableTopMargin: CGFloat = 20.0
internal let kTableBottomMargin: CGFloat = 12.0
internal let kTableSectionTopMargin: CGFloat = 40.0

/// `RSDTableViewCell` is used to display a table cell that is linked to a `RSDTableItem`.
@IBDesignable open class RSDTableViewCell : UITableViewCell, RSDViewDesignable {
    
    /// The index path of the cell.
    public var indexPath: IndexPath!
    
    /// The table item associated with this cell.
    open var tableItem: RSDTableItem!
    
    /// The background color of the containing table.
    // TODO: syoung 03/20/2019 Remove this once the modules that use the `tableBackgroundColor` property are updated.
    @available(*, deprecated)
    open var tableBackgroundColor: UIColor! {
        didSet {
            if let tile = self.tableBackgroundColorTile, tile.color != tableBackgroundColor {
                self.tableBackgroundColorTile = nil
            }
        }
    }
    
    /// Whether or not the table uses light style. 
    // TODO: syoung 03/20/2019 Remove this once the modules that use the `tableBackgroundColor` property are updated.
    @available(*, deprecated)
    open var usesLightStyle: Bool = false
    
    /// Does this cell use the table background color to set the color of the content view?
    open private(set) var usesTableBackgroundColor: Bool = false
    
    /// The background color for the table cell.
    open var backgroundColorTile: RSDColorTile? {
        if usesTableBackgroundColor {
            if let background = tableBackgroundColorTile {
                return background
            }
            else {
                return RSDStudyConfiguration.shared.colorPalette.primary.normal
            }
        }
        else {
            return RSDStudyConfiguration.shared.colorPalette.grayScale.white
        }
    }
    
    /// The background color tile for the table.
    public private(set) var tableBackgroundColorTile: RSDColorTile? {
        didSet {
            guard let color = tableBackgroundColorTile?.color else { return }
            // TODO: syoung 03/20/2019 Remove this once the modules that use the `tableBackgroundColor` property are updated.
            self.tableBackgroundColor = color
        }
    }
    
    /// The design system for this component.
    open private(set) var designSystem: RSDDesignSystem?
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.designSystem = designSystem
        self.tableBackgroundColorTile = background
        if usesTableBackgroundColor {
            self.contentView.backgroundColor = background.color
        }
        if let contentTile = self.backgroundColorTile {
            self.recursiveSetDesignSystem(designSystem, with: contentTile)
        }
    }
}
