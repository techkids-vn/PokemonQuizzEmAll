//
//  JSONToDBLoader.swift
//  PokemonQuizEmAll
//
//  Created by admin on 8/12/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

public class DBLoader: NSObject {
    
    static let jsonFileNames = ["generation1",
                                "generation2",
                                "generation3",
                                "generation4",
                                "generation5",
                                "generation6"]
    
    public static func loadPokemonFromJSONToDBIfNedeed() {
        print("Checking pokemon in database...")
        print("Loading pokemon from JSON to db for the first time...")
        for (_, fileName) in jsonFileNames.enumerate() {
            print("Loading file \(fileName)...", terminator : "")
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                autoreleasepool {
                    print("Loading \(fileName)")
                    let realm = try! Realm()
                    let pokemons = loadPokemonFromSingleJSONToDb(fileName)
                    for pokemon in pokemons {
                        // Check if  the pokemon is already added, if not, add it
                        if realm
                            .objects(Pokemon)
                            .filter(NSPredicate(format: "name = %s", pokemon.name))
                            .count == 0 {
                            try! realm.write {
                                realm.add(pokemon)
                            }
                        }
                    }
                    print("Done")
                }
            }
        }
    }
    
    public static func createSettingIfNeeded() {
        if DB.noSettingInDB() {
            Setting.create()
        }
    }
    
    private static func loadPokemonFromSingleJSONToDb(fileName: String) -> [Pokemon] {
        var pokemons : [Pokemon] = []
        if let file = NSBundle(forClass:AppDelegate.self)
            .pathForResource(fileName, ofType: "json") {
            let data = NSData(contentsOfFile: file)!
            let json = JSON(data:data)
            for index in 0..<json.count{
                let name  = json[index]["name"].string!
                let id    = json[index]["id"].string!
                let img   = json[index]["img"].string!
                let gen   = json[index]["gen"].int!
                let color = json[index]["color"].string!
                let pokemon = Pokemon.create(name, id: id, gen: gen, img: img, color: color)
                pokemons.append(pokemon)
            }
        }
        return pokemons
    }
}
