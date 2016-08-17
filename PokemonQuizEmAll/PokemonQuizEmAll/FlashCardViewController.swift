//
//  FlashCardViewController.swift
//  GRE
//
//  Created by Mr.Vu on 7/9/16.
//  Copyright © 2016 Mr.Vu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
import AVFoundation
import Spring
import CircleProgressView

class FlashCardViewController: UIViewController {
    
    @IBOutlet weak var CircleProgress: CircleProgressView!
    @IBOutlet weak var buttonAnswer1: UIButton!
    @IBOutlet weak var buttonAnswer2: UIButton!
    @IBOutlet weak var buttonAnswer3: UIButton!
    @IBOutlet weak var buttonAnswer4: UIButton!
    
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var viewFlashCard: UIView!
    
    var frontFlashCard : FrontFlashCardViewModel!
    var backFlashCard  : BackFlashCardViewModel!
    var correctAnswerIndex: Int!
    var isFlipping = false
    var currentPokemon : Pokemon?
    var setting : Setting?
    let minusTime = 0.2
    var currentTime = TOTAL_TIME
    var maskLayer: CALayer = CALayer()
    var seenPokemons: [String] = []
    
    var colorVariable : Variable<String> = Variable("")
    var scoreVariable : Variable<Int> = Variable(0)
    
    @IBOutlet weak var maskImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configLayout()
        self.initData()
        self.updateUIWithNewData()
        self.initClickHandlerForButtons()
        self.caculateScore()
        self.changeBackgroundColor()
        self.countTime(minusTime)
        self.prepareAllSfxForPlay()
        
        maskLayer = maskImage.layer
        view.layer.mask = maskLayer
        
        self.navigationController!.navigationBar.barTintColor = .clearColor()
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.navigationBar.backgroundColor = .clearColor()
        self.navigationController!.view.backgroundColor = .clearColor()
        self.navigationController?.navigationBar.tintColor = .whiteColor()
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }
    
    // MARK: initializations
    func initData() {
        print("Getting Setting...")
        self.setting = DB.getSetting()
        
        print("Getting first pokemon")
        self.nextPokemon()
    }
    
    func initClickHandlerForButtons() {
        initClickHandlerFor(self.buttonAnswer1)
        initClickHandlerFor(self.buttonAnswer2)
        initClickHandlerFor(self.buttonAnswer3)
        initClickHandlerFor(self.buttonAnswer4)
    }
    
    func initClickHandlerFor(button: UIButton) {
        _ = button.rx_tap.subscribeNext {
            self.isFlipping = true
            self.buttonUserInteration(false)
            
            var correctButton: UIButton? = nil
            if self.checkAnswer( self.currentPokemon!.name, buttonAnswer: button ) {
                self.scoreVariable.value += 1
                self.soundEffectCorrectPlayer.play()
            }
            else {
                self.soundEffectIncorrectPlayer.play()
                correctButton = self.correctButtonAnswer()
            }
            
            self.revealAnswerAfter(0.9, chosenButton: button, correctButton: correctButton)
        }
    }
    
    func countTime(time : Double) {
        NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: #selector(self.reduceTime), userInfo: nil, repeats: true)
    }
    
    func reduceTime() {
        if isFlipping {return}
        
        if self.currentTime > 0 {
            self.currentTime = max(0, self.currentTime - self.minusTime)
            let scaleTime = self.currentTime/TOTAL_TIME
            self.CircleProgress.progress = scaleTime
        }
        else {
            self.caculateHightScore()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: Animation
    func revealAnswer() {
        
        let frame = CGRectMake(0, 0, self.viewFlashCard.layer.frame.size.width,
                               self.viewFlashCard.layer.frame.size.height)
        self.backFlashCard.frame = frame
        
        UIView.transitionFromView(self.frontFlashCard, toView: self.backFlashCard, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: { _ in
            
            let delay = 1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(time, dispatch_get_main_queue()) {
                self.nextCard();
            }
        })
    }
    
    func nextCard(){
        self.buttonAnswer1.alpha = 0
        self.buttonAnswer2.alpha = 0
        self.buttonAnswer3.alpha = 0
        self.buttonAnswer4.alpha = 0
        UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.backFlashCard.center.x -= self.view.bounds.width
            }, completion: { _ in
                
                //                self.currentPokemon =
                self.nextPokemon()
                UIView.transitionFromView(self.backFlashCard, toView: self.frontFlashCard, duration: 0, options: UIViewAnimationOptions.TransitionNone, completion: nil)
                self.isFlipping = false
                self.updateUIWithNewData()
                
                if self.navigationItem.hidesBackButton && self.currentTime <= 0 {
                    self.caculateHightScore()
                    self.navigationController?.popViewControllerAnimated(true)
                }
                
                self.frontFlashCard.center.x += self.view.bounds.width
                
                UIView.animateWithDuration(0.16, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.frontFlashCard.center.x -= self.view.bounds.width
                    }, completion: { _ in
                        self.buttonAnswer1.alpha = 1
                        self.buttonAnswer2.alpha = 1
                        self.buttonAnswer3.alpha = 1
                        self.buttonAnswer4.alpha = 1
                })
        })
    }
    
    //MARK: Config UI
    func configLayout() {
        // Load FrontFlashCardView
        let frame = CGRectMake(0, 0, self.viewFlashCard.layer.frame.size.width,
                               self.viewFlashCard.layer.frame.size.height)
        self.frontFlashCard = NSBundle.mainBundle().loadNibNamed("FrontFlashCardView", owner: self,options: nil) [0] as! FrontFlashCardViewModel
        self.frontFlashCard.frame = frame
        self.viewFlashCard.addSubview(self.frontFlashCard)
        
        // Load BackFlashCardView
        self.backFlashCard = NSBundle.mainBundle().loadNibNamed("BackFlashCardView", owner: self,
                                                                options: nil) [0] as! BackFlashCardViewModel
        self.backFlashCard.frame = frame
        
        // config button
        self.buttonAnswer1.layer.cornerRadius = self.buttonAnswer1.frame.height/2
        self.buttonAnswer2.layer.cornerRadius = self.buttonAnswer2.frame.height/2
        self.buttonAnswer3.layer.cornerRadius = self.buttonAnswer3.frame.height/2
        self.buttonAnswer4.layer.cornerRadius = self.buttonAnswer4.frame.height/2
        
    }
    
    func changeBackgroundColor() {
        _ = self.colorVariable.asObservable().subscribeNext {
            color in
            if color != "" {
                UIView.animateWithDuration(0.3, animations: {
                    self.view.backgroundColor = UIColor.init(hex: color)
                })
            }
            else {
                let col = self.currentPokemon!.color
                
                UIView.animateWithDuration(0.3, animations: {
                    self.view.backgroundColor = UIColor.init(hex: col)
                })
            }
        }
    }
    
    func buttonUserInteration(block : Bool) {
        self.buttonAnswer1.userInteractionEnabled = block
        self.buttonAnswer2.userInteractionEnabled = block
        self.buttonAnswer3.userInteractionEnabled = block
        self.buttonAnswer4.userInteractionEnabled = block
        self.navigationItem.hidesBackButton = !block
    }
    
    
    //MARK: Chose Answer
    func revealAnswerAfter(time : Double, chosenButton: UIButton, correctButton : UIButton?) {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(round(time * Double(NSEC_PER_SEC))))
        
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.revealAnswer()
            
            if let unwrappedButton: UIButton = correctButton {
                self.visualizeIncorrectAnswer(chosenButton, correctButton: unwrappedButton)
            }
            else{
                self.visualizeCorrectAnswer(chosenButton)
            }
        }
    }
    
    func checkAnswer(answer : String, buttonAnswer : UIButton) -> Bool {
        return (buttonAnswer.titleLabel?.text == answer)
    }
    
    func visualizeCorrectAnswer(correctButton : UIButton) {
        correctButton.backgroundColor = UIColor.init(hex: "#5ad427")
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            correctButton.backgroundColor = UIColor.whiteColor()
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.buttonUserInteration(true)
            }
        }
    }
    
    func visualizeIncorrectAnswer(incorrectButton: UIButton, correctButton: UIButton) {
        correctButton.backgroundColor = UIColor.init(hex: "#5ad427")
        incorrectButton.backgroundColor = UIColor.init(hex: "#FF3A2D")
        
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            correctButton.backgroundColor = UIColor.whiteColor()
            incorrectButton.backgroundColor = UIColor.whiteColor()
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.buttonUserInteration(true)
            }
        }
    }
    
    func correctButtonAnswer() -> UIButton {
        switch self.correctAnswerIndex {
        case 0:
            return buttonAnswer1
        case 1:
            return buttonAnswer2
        case 2:
            return buttonAnswer3
        case 3:
            return buttonAnswer4
        default:
            print("Answer Failed!")
            return UIButton()
        }
    }
    
    //MARK : Score
    func caculateScore() {
        _ = self.scoreVariable.asObservable().subscribeNext {
            score in
            self.labelScore.text = "\(score)"
        }
    }
    
    func caculateHightScore() {
        if DB.getHighScore() == nil {
            HighScore.create(self.scoreVariable.value)
        }
        else if self.scoreVariable.value > DB.getHighScore().score {
            DB.updateHighScore(self.scoreVariable.value)
        }
    }
    
    func updateUIWithNewData() {
        self.frontFlashCard.pokemon = self.currentPokemon
        self.backFlashCard.pokemon = self.currentPokemon
        self.colorVariable.value = self.currentPokemon!.color
        
        self.correctAnswerIndex = Utils.unsafeRandomIntFrom(0, to: 3)
        switch self.correctAnswerIndex {
        case 0:
            self.setPokemonNameFor(buttonAnswer1, failBtn1: buttonAnswer2, failBtn2: buttonAnswer3, failBtn3: buttonAnswer4)
        case 1:
            self.setPokemonNameFor(buttonAnswer2, failBtn1: buttonAnswer1, failBtn2: buttonAnswer3, failBtn3: buttonAnswer4)
        case 2:
            self.setPokemonNameFor(buttonAnswer3, failBtn1: buttonAnswer2, failBtn2: buttonAnswer1, failBtn3: buttonAnswer4)
        case 3:
            self.setPokemonNameFor(buttonAnswer4, failBtn1: buttonAnswer2, failBtn2: buttonAnswer3, failBtn3: buttonAnswer1)
        default:
            print("Random Failed!")
        }
    }
    
    func setPokemonNameFor(trueBtn : UIButton, failBtn1 : UIButton, failBtn2 : UIButton, failBtn3 : UIButton) {
        let pokemons = DB.getRandomPokemons(3, generations: (setting?.pickedGensAsArray)!, exceptNames: seenPokemons)
        let correctPokemon = self.currentPokemon!
        let incorrectPokemon1 = pokemons[0];
        let incorrectPokemon2 = pokemons[1];
        let incorrectPokemon3 = pokemons[2];
        
        trueBtn.setTitle(correctPokemon.name, forState: .Normal)
        failBtn1.setTitle(incorrectPokemon1.name, forState: .Normal)
        failBtn2.setTitle(incorrectPokemon2.name, forState: .Normal)
        failBtn3.setTitle(incorrectPokemon3.name, forState: .Normal)
        self.changeBackgroundColor()
    }
    
    
    func nextPokemon() {
        self.currentPokemon = DB.getRandomPokemon(self.setting!.pickedGensAsArray, exceptNames: seenPokemons)
        seenPokemons.append((self.currentPokemon?.name)!)
    }
    
    // MARK: Sound Effects
    var soundEffectCorrectPlayer = AVAudioPlayer()
    var soundEffectIncorrectPlayer = AVAudioPlayer()
    
    func prepareAllSfxForPlay(){
        soundEffectCorrectPlayer = sfxPlayerForFile("Correct.wav");
        soundEffectIncorrectPlayer = sfxPlayerForFile("Incorrect.wav");
    }
    
    func sfxPlayerForFile(filename: String) -> AVAudioPlayer{
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
}
