//
//  RSDConditionalStepNavigatorObject.swift
//  ResearchSuite
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

/**
 `RSDConditionalStepNavigatorObject` is a concrete implementation of the `RSDConditionalStepNavigator` protocol.
 */
public struct RSDConditionalStepNavigatorObject : RSDConditionalStepNavigator, Decodable {
    
    public private(set) var steps : [RSDStep]
    public var conditionalRule : RSDConditionalRule?
    public var progressMarkers : [String]?
    
    public init(with steps: [RSDStep]) {
        self.steps = steps
    }
    
    private enum CodingKeys : String, CodingKey {
        case steps, conditionalRule, progressMarkers
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let factory = decoder.factory
        
        // Decode the steps
        let stepsContainer = try container.nestedUnkeyedContainer(forKey: .steps)
        self.steps = try factory.decodeSteps(from: stepsContainer)
        
        // Decode the conditional rule
        if container.contains(.conditionalRule) {
            let crDecoder = try container.superDecoder(forKey: .conditionalRule)
            self.conditionalRule = try factory.decodeConditionalRule(from: crDecoder)
        }
        
        // Decode the markers
        self.progressMarkers = try container.decodeIfPresent([String].self, forKey: .progressMarkers)
    }
}