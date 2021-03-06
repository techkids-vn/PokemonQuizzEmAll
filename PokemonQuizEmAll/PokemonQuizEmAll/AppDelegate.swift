//
//  AppDelegate.swift
//  PokemonQuizEmAll
//
//  Created by Mr.Vu on 7/18/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let DB_TEST = false
    let DB_GET_RANDOM_POKEMON_TEST = false
    let DB_GEN_LOADER_TEST = false
    let DB_TEST_FOR_INVALID_PICTURE_IN_POKEMON = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        DBLoader.createSettingIfNeeded()
        DBLoader.loadPokemonFromJSONToDBIfNedeed()
        dbTest()
        
        Utils.prepareAudiosForPlay()
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        return true
    }
    
    func dbTest() -> Void {
        if DB_TEST {
            if DB_GET_RANDOM_POKEMON_TEST {
                var exceptNames : [String] = []
                let generations = DB.getSetting()!.pickedGensAsArray
                for i in 0..<DB.getPokemonCount() {
                    print("Testing pokemon \(i)")
                    let correctPokemon = DB.randomPokemon(generations, exceptNames: exceptNames)
                    assert(!exceptNames.contains(correctPokemon.name))
                    exceptNames.append(correctPokemon.name)
                    
                    let incorrectPokemons = DB.randomPokemons(3, generations: generations, exceptNames: exceptNames)
                    for i in 0..<incorrectPokemons.count-1 {
                        for j in i+1..<incorrectPokemons.count {
                            assert(incorrectPokemons[i].name != incorrectPokemons[j].name)
                            assert(incorrectPokemons[i].name != correctPokemon.name)
                            assert(incorrectPokemons[j].name != correctPokemon.name)
                        }
                    }
                    
                }
            }
            
            if DB_GEN_LOADER_TEST {
                let status = GenLoaderStatus.create(1)
                assert(status.gen == 1)
                
                let statuses = GenLoaderStatus.createFromAllGensIfNeeded()
                var gen = 1
                for status in statuses {
                    assert(status.gen == gen)
                    gen += 1
                }
            }
            
            if DB_TEST_FOR_INVALID_PICTURE_IN_POKEMON {
                for pokemon in DB.getAllPokemons() {
                    let image = UIImage(named: pokemon.img)
                    if image == nil {
                        print("Pokemon has invalid image: gen : \(pokemon.gen); name : \(pokemon.name); img: \(pokemon.img)")
                    }
//                    let imagePath = NSBundle.mainBundle().pathForResource(pokemon.img, ofType: "")
//                    if imagePath != nil {
//                        print("Pokemon has invalid image: gen : \(pokemon.gen); name : \(pokemon.name); img: \(pokemon.img)")
//                    }
                    /*if !NSFileManager.defaultManager().fileExistsAtPath(imagePath!) {
                        
                    }*/
                }
            }
            
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

