//
//  Tools.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/23.
//

import Foundation
import UIKit

class Tools {
    public class var sharedInstance : Tools {
        struct Static {
            static let instance : Tools = Tools()
        }
        
        return Static.instance
    }
    
    public func getPokeID(from url: String) -> String? {
        let pattern = "https://pokeapi.co/api/v\\d+/[a-zA-Z-]+/(\\d+)"

        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsString = url as NSString
            let results = regex.matches(in: url, options: [], range: NSRange(location: 0, length: nsString.length))
            if let match = results.first {
                let idRange = match.range(at: 1)
                let id = nsString.substring(with: idRange)
                return id
            }
        }

        return nil
    }
    
    public func makeFeeback() {
        let impactFeedbackgeneratorLight = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackgeneratorLight.prepare()
        impactFeedbackgeneratorLight.impactOccurred()
    }
}
