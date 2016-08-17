//
//  Util.swift
//  PokemonQuizEmAll
//
//  Created by admin on 8/17/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class Utils: NSObject {
    static func unsafeRandomIntFrom(start: Int, to end: Int) -> Int {
        return Int(arc4random_uniform(UInt32(end - start + 1))) + start
    }
}
