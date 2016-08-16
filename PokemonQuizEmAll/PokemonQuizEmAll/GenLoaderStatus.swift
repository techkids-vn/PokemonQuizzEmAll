//
//  DBLoaderStatus.swift
//  PokemonQuizEmAll
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift

class GenLoaderStatus: Object {
    dynamic var gen = 0
    dynamic var loaded = false
    
    static func create(gen : Int) -> GenLoaderStatus {
        if let status = DB.getGenLoaderStatus(gen) {
            return status
        } else {
            let retVal = GenLoaderStatus()
            retVal.gen = gen
            DB.addGenStatus(retVal)
            return retVal
        }
    }
    
    static func createFromAllGensIfNeeded() -> [GenLoaderStatus] {
        var statuses : [GenLoaderStatus] = []
        for gen in DataConfig.allGens {
            statuses.append(create(gen))
        }
        return statuses
    }
    
    static func getUnloadedGens() -> [Int] {
        return DB.getGenLoaderStatuses(false)
            .map { status in return status.gen }
    }
}
