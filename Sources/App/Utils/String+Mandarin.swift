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
    
    var removingAllSpaces: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}
