//
//  DBLoaderStatus.swift
//  PokemonQuizEmAll
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift

class DBLoaderStatus: Object {
    var done = false
    var genStatuses = List<GenLoaderStatus>()
    
    static func create(genStatuses : [Bool]) {
    }
}

class GenLoaderStatus: Object {
    var gen = -1
    var loaded = false
}
