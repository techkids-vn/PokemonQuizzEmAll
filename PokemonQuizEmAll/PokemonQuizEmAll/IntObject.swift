//
//  IntObject.swift
//  PokemonQuizEmAll
//
//  Created by admin on 8/15/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift


class IntObject: Object {
    dynamic var value = 0
    
    static func create(value: Int) -> IntObject{
        let newIntObject = IntObject()
        newIntObject.value = value
        return newIntObject
    }
    
}
