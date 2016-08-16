//
//  DB.swift
//  GRE
//
//  Created by Do Ngoc Trinh on 7/7/16.
//  Copyright © 2016 Mr.Vu. All rights reserved.
//

import RealmSwift

class DB: Object {
    
    static var realm = try! Realm()
    
//    static func createRealm() {
//        realm = Realm()
//    }
    
    //MARK: Pokemon
    static func addPokemon(pokemon : Pokemon) {
        try! realm.write {
            realm.add(pokemon)
        }
    }
    

    
    
    static func addPokemon(pokemon : Pokemon, realm: Realm) {
        try! realm.write {
            realm.add(pokemon)
        }
    }
    
    static func pokemonExists(name: String) -> Bool {
        return realm
            .objects(Pokemon)
            .filter(NSPredicate(format: "name = %s", name))
            .count > 0
    }
    
    static func getPokemonByName(name : String) -> Pokemon! {
        let predicate = NSPredicate(format: "name = %@", name)
        return realm.objects(Pokemon).filter(predicate).first
    }
    
    static func getPokemonById(id : String) -> Pokemon! {
        let predicate = NSPredicate(format: "id = %@", id)
        return realm.objects(Pokemon).filter(predicate).first
    }
    
    static func noPokemonInDb() -> Bool {
        return realm.objects(Pokemon).count == 0
    }
    
    static func getPokemonCount() -> Int {
        return realm.objects(Pokemon).count
    }
    
//    static func getRandomPokemon(generations : [Int]) -> Pokemon? {
//        
//        var predicate: NSPredicate? = nil
//        for i in 0..<generations.count {
//            let childPredicate = NSPredicate(format: "gen = %d", generations[i])
//            if predicate != nil {
//                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate!, childPredicate])
//            } else {
//                predicate = childPredicate
//            }
//        }
//        
//        if let unwrappedPredicate = predicate {
//            let pokemons = realm.objects(Pokemon).filter(unwrappedPredicate)
//            return pokemons[Int(arc4random_uniform(UInt32(pokemons.count) - 1))]
//        } else {
//            let pokemons = realm.objects(Pokemon)
//            return pokemons[Int(arc4random_uniform(UInt32(pokemons.count) - 1))]
//        }
//    }
    
    static func getRandomPokemons(amount : Int, generations: [Int], exceptNames : [String]) -> [Pokemon] {
        var pokemons : [Pokemon] = []
        var localExceptNames = exceptNames
        
        while pokemons.count < amount {
            let pokemon = getRandomPokemon(generations, exceptNames: [])!
            if !localExceptNames.contains(pokemon.name) {
                pokemons.append(pokemon)
                localExceptNames.append(pokemon.name)
            }
        }

        return pokemons
    }
    
    static func getRandomPokemon(generations : [Int], exceptNames : [String]) -> Pokemon? {
        let orGeneration = predicateIncludeAllGeneration(generations)
        let andExceptName = predicateExceptNames(exceptNames)
        
        var predicate : NSPredicate? = nil
        
        /* Try to combine 2 NSPredicates, ignore one that is nil */
        if let unwrapOrGeneration = orGeneration {
            if let unwrappedAndExceptName = andExceptName {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [unwrapOrGeneration, unwrappedAndExceptName])
            } else {
                predicate = unwrapOrGeneration
            }
        } else if let unwrappedAndExceptName = andExceptName {
            predicate = unwrappedAndExceptName
        }
        
        if let unwrappedPredicate = predicate {
            let pokemons = realm.objects(Pokemon).filter(unwrappedPredicate)
            return pokemons[Int(arc4random_uniform(UInt32(pokemons.count) - 1))]
        } else {
            let pokemons = realm.objects(Pokemon)
            return pokemons[Int(arc4random_uniform(UInt32(pokemons.count) - 1))]
        }
    }
    
    private static func predicateIncludeAllGeneration(generations : [Int]) -> NSPredicate? {
        var predicate: NSPredicate? = nil
        for i in 0..<generations.count {
            let childPredicate = NSPredicate(format: "gen = %d", generations[i])
            if predicate != nil {
                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate!, childPredicate])
            } else {
                predicate = childPredicate
            }
        }
        return predicate
    }
    
    private static func predicateExceptNames(exceptNames : [String]) -> NSPredicate? {
        var predicate: NSPredicate? = nil
        for i in 0..<exceptNames.count {
            let childPredicate = NSPredicate(format: "name != %@", exceptNames[i])
            if predicate != nil {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [])
            } else {
                predicate = childPredicate
            }
        }
        return predicate
    }
    
    //MARK: PACKCARD
    static func createPack(pack : PackCard) {
        try! realm.write {
            realm.add(pack)
        }
    }
    
    static func getPackByName(name:String)->PackCard!{
        let predicate = NSPredicate(format: "name = %@", name)
        return realm.objects(PackCard).filter(predicate).first
    }
    
    static func getAllPacks()->[PackCard]{
        let packs = realm.objects(PackCard)
        var returnPacks = [PackCard]()
        for pack:PackCard in packs {
            returnPacks.append(pack)
        }
        return returnPacks
    }
    
    static func getNumberTagOfPack(pack: PackCard, tag:String) -> Int!{
        let findPack = getPackByName(pack.name)
        var numberCount = 0
        for card:Card in findPack.cards {
            if(card.tag == tag){
                numberCount += 1
            }
        }
        return numberCount
    }
    
    //MARK: CARD
    static func createCard(card : Card){
        try! realm.write{
            realm.add(card)
        }
    }
    
    static func getAllCards()->[Card]!{
        let cards = realm.objects(Card)
        var returnCards = [Card]()
        for card:Card in cards {
            returnCards.append(card)
        }
        return returnCards
    }
    
    static func getCardByWord(word : String) -> Card! {
        let predicate = NSPredicate(format: "word = %@", word)
        return realm.objects(Card).filter(predicate).first
    }
    
    static func getCardInPack(pack : PackCard, word : String) -> Card! {
        var card  : Card!
        for c in pack.cards {
            if c.word == word {
                card = c
            }
        }
        return card
    }
    
    static func updateTag(pack : PackCard,word : String, tag : String) {
        for card in pack.cards {
            if card.word == word {
                try! realm.write {
                    card.tag = tag
                }
            }
        }
        
    }
    static func updateTag(card : Card, tag : String) {
        try! realm.write {
            card.tag = tag
        }
    }
    
    //MARK: HighScore
    static func createHighScore(highScore: HighScore){
        try! realm.write{
            realm.add(highScore)
        }
    }
    static func updateHighScore(score : Int){
        let highScore = realm.objects(HighScore).first
        if(highScore != nil){
            try! realm.write {
                if(highScore?.score < score){
                    highScore?.score = score
                }
            }
        }else{
            HighScore.create(score)
            DB.updateHighScore(score)
        }
    }
    
    static func getHighScore() -> HighScore! {
        return (realm.objects(HighScore).first)
    }
    
    //MARK: Setting
    static func addSetting(setting : Setting){
        try! realm.write {
            realm.add(setting)
        }
    }
    
    static func updateSetting(turnOffSound: Int, turnOffMusic: Int){
        let setting = realm.objects(Setting).first
        if(setting != nil){
            try! realm.write {
                if(turnOffSound==0 || turnOffSound == 1){
                    setting?.turnOffSound = turnOffSound
                }
                if(turnOffMusic == 0 || turnOffMusic == 1){
                    setting?.turnOffMusic = turnOffMusic
                }
            }
        }else {
            Setting.create()
            DB.updateSetting(turnOffSound, turnOffMusic: turnOffMusic)
        }
    }
    
    static func updateSettings(turnOffSound: Int, turnOffMusic: Int, listGens: [Int]){
        let setting = realm.objects(Setting).first
        if(setting != nil) {
            try! realm.write {
                if(turnOffSound==0 || turnOffSound == 1){
                    setting?.turnOffSound = turnOffSound
                }
                if(turnOffMusic == 0 || turnOffMusic == 1){
                    setting?.turnOffMusic = turnOffMusic
                }
                if(listGens.count <= 0){
                    // setting?.pickedGens.append(IntObject.create(0))
                }
                else{
                    setting?.pickedGens.removeAll()
                    for indexGen: Int in listGens{
                        let newIntObject = IntObject.create(indexGen)
                        setting?.pickedGens.append(newIntObject)
                    }
                }
            }
        }else {
            Setting.create()
            DB.updateSettings(turnOffSound, turnOffMusic: turnOffMusic,listGens: listGens)
        }
    }
    
    static func getSoundOn()->Bool{
        let setting = realm.objects(Setting).first
        if(setting != nil){
            if(setting?.turnOffSound == 1){
                return false
            }
        }
        return true
    }
    
    static func getMusicOn()->Bool{
        let setting = realm.objects(Setting).first
        if(setting != nil){
            if(setting?.turnOffMusic == 1){
                return false
            }
        }
        return true
    }
    
    static func flipGen(setting: Setting, gen: Int) {
        try! realm.write {
            setting.flipGen(gen)
        }
    }
    
    static func getPickedGen()->[Int]{
        let setting = realm.objects(Setting).first
        var pickedGen = [Int]()
        if(setting != nil){
            for genIndex:IntObject in (setting?.pickedGens)! {
                pickedGen.append(genIndex.value)
            }
        }
        else {
            pickedGen.append(0)
            DB.updateSettings(-1, turnOffMusic: -1, listGens: pickedGen)
        }
        return pickedGen
    }
    
    static func checkSettingsStatus(){
        print("sound: \(DB.getSoundOn()) - music: \(DB.getMusicOn()) - genCount : \(DB.getPickedGen().count)")
    }
    
    static func noSettingInDB() -> Bool {
        return realm.objects(Setting).count == 0
    }
    
    static func getSetting() -> Setting? {
        return realm.objects(Setting).first
    }
}
