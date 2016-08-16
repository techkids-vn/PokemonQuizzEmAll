//
//  Settings.swift
//  GRE
//
//  Created by Do Ngoc Trinh on 7/13/16.
//  Copyright © 2016 Mr.Vu. All rights reserved.
//

import Foundation
import RealmSwift

class Setting : Object{
    dynamic var turnOffSound : Int = 0
    dynamic var turnOffMusic: Int = 0
    var pickedGens = List<IntObject>()
    
    static func create() -> Setting {
        let setting = Setting()
        setting.setPickedGens(DataConfig.allGens)
        DB.addSetting(setting)
        return setting
    }
}

extension Setting {
    var pickedGensAsArray : [Int] {
        get {
            return self.pickedGens
                .filter { inObj in return inObj.value != 0 }
                .map { inObj in return inObj.value }
        }
    }
    
    func setPickedGens(gens: [Int]) {
        self.pickedGens.removeAll()
        self.pickedGens.appendContentsOf(gens.map {
                gen in
                return IntObject.create(gen)
            })
    }
    
    func findPickedGen(gen : Int) -> IntObject? {
        let foundGens = self.pickedGens.filter {
            pickedGen in
            return pickedGen.value == gen
        }
        if foundGens.count > 0 {
            return foundGens[0]
        } else {
            return nil
        }
    }

    func genIsPicked(gen : Int) -> Bool {
        return findPickedGen(gen) != nil
    }
    
    func flipGen(gen : Int) -> Bool {
        let pickedGen = findPickedGen(gen)
        if let uwrPickedGen = pickedGen {
            if self.pickedGens.count > 1 {
                self.pickedGens.removeAtIndex(self.pickedGens.indexOf(uwrPickedGen)!)
            }
            return false
        } else {
            self.pickedGens.append(IntObject.create(gen))
            return true
        }
    }
    
    func printPickedGens() {
        for gen in self.pickedGens {
            print("Gen: \(gen)")
        }
    }
}

