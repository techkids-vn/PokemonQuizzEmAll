//
//  PlayViewController.swift
//  PokemonQuizEmAll
//
//  Created by Do Ngoc Trinh on 7/18/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController {
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblHighScoreTitle: UILabel!
    @IBOutlet weak var lblHighScore: UILabel!
    
    let ad = AppDelegate()
    let transition = FlashCardViewRevealAnimator()
    
    override func viewWillAppear(animated: Bool) {
        setUpColor()
        if DB.getHighScore() != nil {
            lblHighScore.text = "\(DB.getHighScore().score)"
        }
        else {
            lblHighScore.text = "0"
        }
        
        lblHighScore.numberOfLines = 1;
        lblHighScore.adjustsFontSizeToFitWidth = true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBtn()
        DB.checkSettingsStatus()
        navigationController?.delegate = self
        
//        playBackgroundMusic("PokemonThemeSong.mp3")
    }
    var backgroundMusicPlayer = AVAudioPlayer()
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: newURL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func setUpColor(){
        self.navigationController!.navigationBar.barTintColor = .clearColor()
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.navigationBar.backgroundColor = .clearColor()
        self.navigationController!.view.backgroundColor = .clearColor()
    }
    
    func setUpBtn()
    {
        btnPlay.addTarget(self, action: #selector(play), forControlEvents: .TouchUpInside)
        addBarButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addBarButton(){
        
        let title = UILabel.init(frame: CGRectMake(0, 0, self.view.bounds.width, 40))
        title.textAlignment = .Left
        title.text = "Quiz 'Em All"
        title.textColor = UIColor.init(hex: "212121")
        self.navigationItem.titleView = title
        
        let btnSettings : UIButton = UIButton.init(frame: CGRectMake(0, 0, 30, 30))
        btnSettings.setImage(UIImage.init(named: "Icon_Settings"), forState: .Normal)
        btnSettings.addTarget(self, action: #selector(btnSettingsDidTap), forControlEvents: .TouchUpInside)
        let btnBarSettings : UIBarButtonItem = UIBarButtonItem.init(customView: btnSettings)
        self.navigationItem.setRightBarButtonItem(btnBarSettings, animated: true)
    }
    
    func play(){
        let flashCard : FlashCardViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("FlashCardViewController") as? FlashCardViewController)!
        
        self.navigationController?.pushViewController(flashCard, animated: true)
    }
    //MARK: Button Settings
    
    @IBAction func btnSettingsDidTap(sender: AnyObject) {
                let settingsVC : SettingsViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
                self.navigationController?.pushViewController(settingsVC, animated: true)
    }
}

extension PlayViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let fromMirror = Mirror(reflecting: fromVC)
        let toMirror = Mirror(reflecting: toVC)
        
        if toMirror.subjectType == FlashCardViewController.self {
            transition.operation = operation
            return transition
        }
            
        if fromMirror.subjectType == FlashCardViewController.self && toMirror.subjectType == PlayViewController.self{
            
            transition.operation = operation
            return transition
        }
        
        return nil
    }
}
