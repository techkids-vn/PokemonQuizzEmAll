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
    @IBOutlet weak var btnAnswer3: UIButton!
    @IBOutlet weak var btnAnswer4: UIButton!
    @IBOutlet weak var btnAnswer2: UIButton!
    @IBOutlet weak var btnAnswer1: UIButton!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var vFlashCard: UIView!

    var frontFlashCard : FrontFlashCardViewModel!
    var backFlashCard  : BackFlashCardViewModel!
    var trueAnswerIndex: Int!
    var isFlip = false
    //var currentPokemon = 0
    //var totalPokemon = 0
    //var pokemonCollection = [Pokemon]()
    var currentPokemon : Pokemon?
    var setting : Setting?
    let minusTime = 0.2
    var currentTime = TOTAL_TIME
    var maskLayer: CALayer = CALayer()
    
    var colorVariable : Variable<String> = Variable("")
    var scoreVariable : Variable<Int> = Variable(0)
    
    @IBOutlet weak var maskImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configLayout()
        self.initData()
        self.bindingData()
//        self.dumpData()
        self.clickOnButton()
        self.caculateScore()
        self.changeBackgroundColor()
        self.countTime(minusTime)
        
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
    
    //MARK: Animation
    func flipFlashCard() {
        self.isFlip = true
        let frame = CGRectMake(0, 0, self.vFlashCard.layer.frame.size.width,
                               self.vFlashCard.layer.frame.size.height)
        self.backFlashCard.frame = frame

        UIView.transitionFromView(self.frontFlashCard, toView: self.backFlashCard, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: { _ in
            
            let delay = 1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(time, dispatch_get_main_queue()) {
                self.nextCard();
            }
        })
    }
    
    
    
    func initData() {
        print("Getting Setting...")
        self.setting = DB.getSetting()
        
        print("Getting first pokemon")
        self.getNextPokemon()
    }
    
    func initLayout() {
        
    }
    
    func nextCard(){
        self.btnAnswer1.alpha = 0
        self.btnAnswer2.alpha = 0
        self.btnAnswer3.alpha = 0
        self.btnAnswer4.alpha = 0
        UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.backFlashCard.center.x -= self.view.bounds.width
            }, completion: { _ in
                
//                self.currentPokemon = 
                self.getNextPokemon()
                UIView.transitionFromView(self.backFlashCard, toView: self.frontFlashCard, duration: 0, options: UIViewAnimationOptions.TransitionNone, completion: nil)
                self.isFlip = false
                self.bindingData()
                
                if self.navigationItem.hidesBackButton && self.currentTime <= 0 {
                    self.caculateHightScore()
                    self.navigationController?.popViewControllerAnimated(true)
                }
                
                self.frontFlashCard.center.x += self.view.bounds.width
                
                UIView.animateWithDuration(0.16, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        self.frontFlashCard.center.x -= self.view.bounds.width
                    }, completion: { _ in
                        self.btnAnswer1.alpha = 1
                        self.btnAnswer2.alpha = 1
                        self.btnAnswer3.alpha = 1
                        self.btnAnswer4.alpha = 1
                })
        })
    }
    
    //MARK: Config UI
    func configLayout() {
        // Load FrontFlashCardView
        let frame = CGRectMake(0, 0, self.vFlashCard.layer.frame.size.width,
                                        self.vFlashCard.layer.frame.size.height)
        self.frontFlashCard = NSBundle.mainBundle().loadNibNamed("FrontFlashCardView", owner: self,options: nil) [0] as! FrontFlashCardViewModel
        self.frontFlashCard.frame = frame
        self.vFlashCard.addSubview(self.frontFlashCard)
        
        // Load BackFlashCardView
        self.backFlashCard = NSBundle.mainBundle().loadNibNamed("BackFlashCardView", owner: self,
            options: nil) [0] as! BackFlashCardViewModel
        self.backFlashCard.frame = frame
        
        // config button
        self.btnAnswer1.layer.cornerRadius = self.btnAnswer1.frame.height/2
        self.btnAnswer2.layer.cornerRadius = self.btnAnswer2.frame.height/2
        self.btnAnswer3.layer.cornerRadius = self.btnAnswer3.frame.height/2
        self.btnAnswer4.layer.cornerRadius = self.btnAnswer4.frame.height/2

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
        self.btnAnswer1.userInteractionEnabled = block
        self.btnAnswer2.userInteractionEnabled = block
        self.btnAnswer3.userInteractionEnabled = block
        self.btnAnswer4.userInteractionEnabled = block
        self.navigationItem.hidesBackButton = !block
    }
    
    
    //MARK: Chose Answer
    func delayThenFlipCard(time : Double) {
        NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: #selector(self.flipFlashCard), userInfo: nil, repeats: false)
    }
    
    func countTime(time : Double) {
        NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: #selector(self.reduceTime), userInfo: nil, repeats: true)
    }
    
    func reduceTime() {
        if isFlip {return}
        
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
    
    func clickOnButton() {
        _ = self.btnAnswer1.rx_tap.subscribeNext {
            self.buttonUserInteration(false)
            self.showAnswer()
            if self.checkAnswer(
                self.currentPokemon!.name,
                btnAnswer: self.btnAnswer1) {
                
                self.trueAnsert(self.btnAnswer1)
            }
            else {
                self.findTrueAnswer()
            }
        }
        
        _ = self.btnAnswer2.rx_tap.subscribeNext {
            self.buttonUserInteration(false)
            self.showAnswer()
            if self.checkAnswer(self.currentPokemon!.name, btnAnswer: self.btnAnswer2) {
                self.trueAnsert(self.btnAnswer2)
            }
            else {
                self.findTrueAnswer()
            }
        }
        
        _ = self.btnAnswer3.rx_tap.subscribeNext {
            self.buttonUserInteration(false)
            self.showAnswer()
            if self.checkAnswer(self.currentPokemon!.name, btnAnswer: self.btnAnswer3) {
                self.trueAnsert(self.btnAnswer3)
            }
            else {
                self.findTrueAnswer()
            }
        }
        
        _ = self.btnAnswer4.rx_tap.subscribeNext {
            self.buttonUserInteration(false)
            self.showAnswer()
            if self.checkAnswer(self.currentPokemon!.name, btnAnswer: self.btnAnswer4) {
                self.trueAnsert(self.btnAnswer4)
            }
            else {
                self.findTrueAnswer()
            }
        }
    }
    
    func showAnswer() {
      // self.changeBackgroundColor()
        self.delayThenFlipCard(0)
    }
    
    func checkAnswer(answer : String, btnAnswer : UIButton) -> Bool {
        if btnAnswer.titleLabel?.text == answer {
            self.scoreVariable.value += 1
            return true
        }
        return false
    }
    
    func trueAnsert(trueBtn : UIButton) {
        trueBtn.backgroundColor = UIColor.init(hex: "#5ad427")
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            trueBtn.backgroundColor = UIColor.whiteColor()
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.buttonUserInteration(true)
            }

        }

    }
    
    func falseAnswer(trueBtn : UIButton, failButton1 : UIButton, failButton2 : UIButton, failButton3 : UIButton) {
        trueBtn.backgroundColor = UIColor.init(hex: "#5ad427")
        failButton1.backgroundColor = UIColor.init(hex: "#FF3A2D")
        failButton2.backgroundColor = UIColor.init(hex: "#FF3A2D")
        failButton3.backgroundColor = UIColor.init(hex: "#FF3A2D")
        
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            trueBtn.backgroundColor = UIColor.whiteColor()
            failButton1.backgroundColor = UIColor.whiteColor()
            failButton2.backgroundColor = UIColor.whiteColor()
            failButton3.backgroundColor = UIColor.whiteColor()
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.buttonUserInteration(true)
            }
        }
    }
    
    func findTrueAnswer() {
        switch self.trueAnswerIndex {
        case 0:
            self.falseAnswer(btnAnswer1, failButton1: btnAnswer2, failButton2: btnAnswer3, failButton3: btnAnswer4)
        case 1:
            self.falseAnswer(btnAnswer2, failButton1: btnAnswer1, failButton2: btnAnswer3, failButton3: btnAnswer4)
        case 2:
            self.falseAnswer(btnAnswer3, failButton1: btnAnswer2, failButton2: btnAnswer1, failButton3: btnAnswer4)
        case 3:
            self.falseAnswer(btnAnswer4, failButton1: btnAnswer2, failButton2: btnAnswer3, failButton3: btnAnswer1)
        default:
            print("Answer Failed!")
        }
    }

    //MARK : Score
    func caculateScore() {
        _ = self.scoreVariable.asObservable().subscribeNext {
            score in
            self.lblScore.text = "\(score)"
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
    
    //MARK: Load data
//    func dumpData() {
//        
//        if let file = NSBundle(forClass:AppDelegate.self).pathForResource("gen1", ofType: "json") {
//            let data = NSData(contentsOfFile: file)!
//            let json = JSON(data:data)
//            self.totalPokemon = json.count
//            for index in 0..<json.count{
//                let name  = json[index]["name"].string!
//                let id    = json[index]["id"].string!
//                let img   = json[index]["img"].string!
//                let gen   = json[index]["gen"].int!
//                let color = json[index]["color"].string!
//                if DB.getPokemonByName(name) == nil {
//                    let pokemon = Pokemon.create(name, id: id, gen: gen, img: img, color: color)
//                    self.pokemonCollection.append(pokemon)
//                }
//                else {
//                    let pokemon = DB.getPokemonByName(name)
//                    self.pokemonCollection.append(pokemon)
//                }
//            }
//            self.currentPokemon = self.unsafeRandomIntFrom(0, to: self.totalPokemon - 1)
//            self.bindingData()
//        } else {
//            print("file not exists")
//        }
//    }
    
    func matchingData() {
        self.frontFlashCard.pokemon = self.currentPokemon // self.pokemonCollection[self.currentPokemon]
        self.backFlashCard.pokemon = self.currentPokemon //self.pokemonCollection[self.currentPokemon]
        self.colorVariable.value = self.currentPokemon!.color
    }
    
    func bindingData() {
        self.matchingData()
        let trueAnswerIndex = self.unsafeRandomIntFrom(0, to: 3)
        self.trueAnswerIndex = trueAnswerIndex
        switch trueAnswerIndex {
        case 0:
            self.setTitleForButton(btnAnswer1, failBtn1: btnAnswer2, failBtn2: btnAnswer3, failBtn3: btnAnswer4)
        case 1:
            self.setTitleForButton(btnAnswer2, failBtn1: btnAnswer1, failBtn2: btnAnswer3, failBtn3: btnAnswer4)
        case 2:
            self.setTitleForButton(btnAnswer3, failBtn1: btnAnswer2, failBtn2: btnAnswer1, failBtn3: btnAnswer4)
        case 3:
            self.setTitleForButton(btnAnswer4, failBtn1: btnAnswer2, failBtn2: btnAnswer3, failBtn3: btnAnswer1)
        default:
           print("Random Failed!")
        }
    }
    
    func setTitleForButton(trueBtn : UIButton, failBtn1 : UIButton, failBtn2 : UIButton, failBtn3 : UIButton) {
        let pokemon = self.currentPokemon!
        let pokemon1 = self.getRandomPokemon()
        //self.pokemonCollection[self.randomFailAnswer(self.currentPokemon)]
        let pokemon2 = self.getRandomPokemon()
        //self.pokemonCollection[self.randomFailAnswer(self.currentPokemon)]
        let pokemon3 = self.getRandomPokemon()
            //self.pokemonCollection[self.randomFailAnswer(self.currentPokemon)]
        
        trueBtn.setTitle(pokemon.name, forState: .Normal)
        failBtn1.setTitle(pokemon1!.name, forState: .Normal)
        failBtn2.setTitle(pokemon2!.name, forState: .Normal)
        failBtn3.setTitle(pokemon3!.name, forState: .Normal)
        self.changeBackgroundColor()
    }
    
//    func randomFailAnswer(currentIndex : Int) -> Int {
//        var rand = unsafeRandomIntFrom(0, to: self.totalPokemon - 2)
//        
//        if(rand >= currentIndex) {
//            rand += 1
//        }
//        
//        return rand
//    }
//    
    func unsafeRandomIntFrom(start: Int, to end: Int) -> Int {
        return Int(arc4random_uniform(UInt32(end - start + 1))) + start
    }
    
    func getNextPokemon() {
        self.currentPokemon = self.getRandomPokemon()
    }
    
    func getRandomPokemon() -> Pokemon? {
        return DB.getRandomPokemon(self.setting!.pickedGensAsArray)
    }
}
