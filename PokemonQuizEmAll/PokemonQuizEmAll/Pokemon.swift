//
//  Gen.swift
//  PokemonQuizEmAll
//
//  Created by Mr.Vu on 7/18/16.
//  Copyright © 2016 vu. All rights reserved.
//

import RealmSwift
class Pokemon: Object {
    dynamic var color : String = ""
    dynamic var gen   : Int = 0
    dynamic var id    : String = ""
    dynamic var img   : String = ""
    dynamic var name  : String = ""
    
    static func create(name: String, id: String, gen: Int, img: String, color : String) -> Pokemon {
        let pokemon = Pokemon()
        pokemon.name = name
        pokemon.id = id
        pokemon.gen = gen
        pokemon.img = img
        pokemon.color = color
        DB.addPokemon(pokemon)
        return pokemon
    }
}
