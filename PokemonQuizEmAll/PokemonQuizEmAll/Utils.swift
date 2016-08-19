//
//  Util.swift
//  PokemonQuizEmAll
//
//  Created by admin on 8/17/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import AVFoundation

class Utils: NSObject {
    // MARK: Helper Functions
    static func unsafeRandomIntFrom(start: Int, to end: Int) -> Int {
        return Int(arc4random_uniform(UInt32(end - start + 1))) + start
    }
    
    // MARK: Audio
    static var menuMusicPlayer = AVAudioPlayer()
    static var gameplayMusicPlayer = AVAudioPlayer()
    static var soundEffectCorrectPlayer = AVAudioPlayer()
    static var soundEffectIncorrectPlayer = AVAudioPlayer()
    static var soundEffectTogglePlayer = AVAudioPlayer()
    static var soundEffectClickPlayer = AVAudioPlayer()
    
    static func prepareAudiosForPlay(){
        soundEffectCorrectPlayer = sfxPlayerForFile("firered_00FA.wav")
        soundEffectIncorrectPlayer = sfxPlayerForFile("firered_00A3.wav")
        soundEffectTogglePlayer = sfxPlayerForFile("UIToggle.wav")
        soundEffectClickPlayer = sfxPlayerForFile("UIClick.wav")
        if(!DB.getSoundOn()){
            setSfxVolume(0)
        }
        
        menuMusicPlayer = musicPlayerForFile("Quirky-Puzzle-Game-Menu.mp3")
        gameplayMusicPlayer = musicPlayerForFile("8-Bit-Mayhem.mp3")
        if(!DB.getMusicOn()){
            setMusicVolume(0)
        }
    }
    
    static func setSfxVolume(volume: Float){
        soundEffectCorrectPlayer.volume = volume
        soundEffectIncorrectPlayer.volume = volume
        soundEffectTogglePlayer.volume = volume
        soundEffectClickPlayer.volume = volume
    }
    
    static func setMusicVolume(volume: Float){
        menuMusicPlayer.volume = volume
        gameplayMusicPlayer.volume = volume
    }
    
    private static func sfxPlayerForFile(filename: String) -> AVAudioPlayer{
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return AVAudioPlayer()
        }
        do {
            let player = try AVAudioPlayer(contentsOfURL: newURL)
            player.numberOfLoops = 0
            player.prepareToPlay()
            return player
        } catch let error as NSError {
            print(error.description)
        }
        
        return AVAudioPlayer()
    }
    
    private static func musicPlayerForFile(filename: String) -> AVAudioPlayer{
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return AVAudioPlayer()
        }
        do {
            let player = try AVAudioPlayer(contentsOfURL: newURL)
            player.numberOfLoops = -1
            player.prepareToPlay()
            return player
        } catch let error as NSError {
            print(error.description)
        }
        
        return AVAudioPlayer()
    }
}
