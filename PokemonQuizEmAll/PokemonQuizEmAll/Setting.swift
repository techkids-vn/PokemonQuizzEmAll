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
        setting.pickedGens.append(IntObject.create(0))
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
}

