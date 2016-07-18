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

class FlashCardViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
    @IBOutlet weak var btnAnswer3: UIButton!
    @IBOutlet weak var btnAnswer4: UIButton!
    @IBOutlet weak var btnAnswer2: UIButton!
    @IBOutlet weak var btnAnswer1: UIButton!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var vFlashCard: UIView!

    var frontFlashCard : FrontFlashCardViewModel!
    var backFlashCard  : BackFlashCardViewModel!
    var isFlip = false
    var currentCard = 0
    var cardCollection = [Card]()
    var currentPack : PackCard!
    var packIndex : Int!

    override func viewWillAppear(animated: Bool) {
       // configColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configLayout()
        self.dumpData()
        
//        self.frontFlashCard.card = self.cardCollection[self.currentCard]
//        self.backFlashCard.card  = self.cardCollection[self.currentCard]
        

        vFlashCard.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init()
        _ = tapGesture.rx_event.subscribeNext {
            gestureReconizer in
            self.flipFlashCard()
        }
        self.vFlashCard.addGestureRecognizer(tapGesture)
    }
    
    //MARK: Animation
    func flipFlashCard() {
        let frame = CGRectMake(0, 0, self.vFlashCard.layer.frame.size.width,
                               self.vFlashCard.layer.frame.size.height)
        self.backFlashCard.frame = frame
        updateLayout()
        if !self.isFlip {
            UIView.transitionFromView(frontFlashCard, toView: backFlashCard, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            self.isFlip = true
        }
        else {
            UIView.transitionFromView(backFlashCard, toView: frontFlashCard, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
            self.isFlip = false
        }
    }
    
    func nextCard(view : SpringView) {
        view.delay = 0.1
        view.velocity = 0.5
        view.animateNext {
            view.animation = "slideRight"
            view.animateTo()
            view.x = self.view.bounds.width + self.vFlashCard.bounds.width
            view.animateToNext {
                view.animate()
            }
            view.x = 0
            view.animateToNext {
                view.animateTo()
            //    self.setButtuonEnable(true)
            }
        }
    }
    
    //MARK: Config UI
//    func configColor(){
//        //set backgorund View
//        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
//        UIView .animateWithDuration(0.2) {
//        }
//        
//    }
    
    func updateLayout(){
        self.vFlashCard.layoutIfNeeded()
        self.vFlashCard.setNeedsLayout()
        self.backFlashCard.setNeedsLayout()
        self.backFlashCard.layoutIfNeeded()
        let frameFrontCard = CGRectMake(0, 0, self.vFlashCard.layer.frame.size.width,
                                        self.vFlashCard.layer.frame.size.height)
        self.frontFlashCard.frame = frameFrontCard
    }
    
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
    
    //MARK: Dump data
    func dumpData() {
        
//        for index in 0..<self.currentPack.cards.count {
//            let jsonCard = self.currentPack.cards[index]
//            let word     = jsonCard.word
//            let type     = jsonCard.type
//            let script   = jsonCard.script
//            let tag      = jsonCard.tag
//            
//            if DB.getCardByWord(word) == nil {
//                let card = Card.create(word, type: type, script: script, tag: tag)
//                self.cardCollection.append(card)
//            }
//            else {
//                self.cardCollection.append(DB.getCardInPack(self.currentPack, word: word))
//            }
//        }
//        self.bindingData()
    }
    
    func bindingData() {
//        
//        _ = self.btnNotKnew.rx_tap.subscribeNext {
//            UIView.transitionFromView(self.backFlashCard, toView: self.frontFlashCard, duration: 0, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
//            self.setButtuonEnable(false)
//            self.isFlip = false
//            self.nextCard(self.frontFlashCard)
//            self.synthesizer.stopSpeakingAtBoundary(.Word)
//            self.isFlip = false
//            let card = self.cardCollection[self.currentCard]
//            if card.tag == MASTER_TAG {
//                DB.updateTag(self.currentPack, word: card.word, tag: LEARNING_TAG)
//                self.numberOfMaster.value -= 1
//                self.numberOfLearning.value += 1
//            }
//            else if card.tag == REVIEW_TAG {
//                DB.updateTag(self.currentPack, word: card.word, tag: LEARNING_TAG)
//                self.numberOfReviewing.value -= 1
//                self.numberOfLearning.value += 1
//            }
//            else if card.tag == NEW_WORD_TAG {
//                DB.updateTag(self.currentPack, word: card.word, tag: LEARNING_TAG)
//                self.numberOfLearning.value += 1
//            }
//            
//            self.currentCard += 1
//            if self.currentCard == self.cardCollection.count {
//                self.currentCard = 0
//            }
//            self.frontFlashCard.card = self.cardCollection[self.currentCard]
//            self.backFlashCard.card  = self.cardCollection[self.currentCard]
//        }
//        
//        _ = self.btnKnew.rx_tap.subscribeNext {
//            UIView.transitionFromView(self.backFlashCard, toView: self.frontFlashCard, duration: 0, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
//            self.isFlip = false
//            self.setButtuonEnable(false)
//            self.nextCard(self.frontFlashCard)
//            self.synthesizer.stopSpeakingAtBoundary(.Word)
//            self.isFlip = false
//            let card = self.cardCollection[self.currentCard]
//            if card.tag == NEW_WORD_TAG {
//                DB.updateTag(self.currentPack, word: card.word, tag: MASTER_TAG)
//                self.numberOfMaster.value += 1
//            }
//            else if card.tag == REVIEW_TAG {
//                DB.updateTag(self.currentPack, word: card.word, tag: MASTER_TAG)
//                self.numberOfMaster.value += 1
//                self.numberOfReviewing.value -= 1
//            }
//            else if card.tag == MASTER_TAG {
//                
//            }
//            else if card.tag == LEARNING_TAG {
//                DB.updateTag(self.currentPack, word: card.word, tag: REVIEW_TAG)
//                self.numberOfReviewing.value += 1
//                self.numberOfLearning.value  -= 1
//            }
//            
//            self.currentCard += 1
//            if self.currentCard == self.cardCollection.count {
//                self.currentCard = 0
//            }
//            self.frontFlashCard.card = self.cardCollection[self.currentCard]
//            self.backFlashCard.card  = self.cardCollection[self.currentCard]
//        }
        
    }
    
    }
