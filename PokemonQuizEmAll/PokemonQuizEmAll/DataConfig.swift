//
//  DataConfig.swift
//  PokemonQuizEmAll
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class DataConfig: NSObject {
    static let allGens = [1, 2, 3, 4, 5, 6]
    static func getJsonFileNames() -> [String] {
        return allGens.map {
            gen in
            return "generation\(gen)"
        }
    }
}
