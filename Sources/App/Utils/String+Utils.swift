//
//  String+Utils.swift
//  App
//
//  Created by Otávio Zabaleta on 29/11/2018.
//

import Foundation

extension String {
    var trimmingSpaces: String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }
}
