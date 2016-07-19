//
//  HighScore.swift
//  PokemonQuizEmAll
//
//  Created by Do Ngoc Trinh on 7/19/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import RealmSwift

class HighScore : Object{
    dynamic var score : Int = 0
    static func create() -> HighScore {
        let highScore = HighScore()
        DB.createHighScore(highScore)
        return highScore
    }
}