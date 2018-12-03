//
//  Validator+Utils.swift
//  App
//
//  Created by Otávio Zabaleta on 03/12/2018.
//

import Vapor

extension Validator {
    static var genericTextValidator: Validator<String> {
        var set = CharacterSet.whitespaces.union(CharacterSet.alphanumerics)
        set = set.union(CharacterSet(charactersIn: "£$%@#*&€;:'<>[]{}+=-_\\"))
        set = set.union(CharacterSet.punctuationCharacters)
        return Validator<String>.characterSet(set)
    }
    
    static var listNamingValidator: Validator<String> {
        let set = CharacterSet.whitespaces.union(CharacterSet.alphanumerics)
        return Validator<String>.characterSet(set)
    }
}
