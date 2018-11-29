//
//  String+Mandarin.swift
//  App
//
//  Created by Otávio Zabaleta on 29/11/2018.
//

import Foundation

extension String {
    var containsChineseCharacters: Bool {
        return self.range(of: "\\p{Han}", options: .regularExpression) != nil
    }
    
    var containsOnlyChineseCharacters: Bool {
        guard let range = self.range(of: "\\p{Han}*\\p{Han}", options: .regularExpression) else { return false }
        switch range {
        case self.startIndex..<self.endIndex:
            return true
        default:
            return false
        }
    }
    
    var removingAllSpaces: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}
