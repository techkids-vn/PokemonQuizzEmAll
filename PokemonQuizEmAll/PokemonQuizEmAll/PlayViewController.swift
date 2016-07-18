//
//  PlayViewController.swift
//  PokemonQuizEmAll
//
//  Created by Do Ngoc Trinh on 7/18/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {

    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblHighScoreTitle: UILabel!
    @IBOutlet weak var lblHighScore: UILabel!
   
    override func viewWillAppear(animated: Bool) {
        lblHighScore.text = "9999"
        
        lblHighScore.numberOfLines = 1;
        lblHighScore.adjustsFontSizeToFitWidth = true;
        //lblHighScore.numberOfLines = 0//will wrap text in new line
       // lblHighScore.sizeToFit()
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBtn()

    }
    
    func setUpBtn()
    {
        btnPlay.addTarget(self, action: #selector(play), forControlEvents: .TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func play(){
        let flashCard : FlashCardViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("FlashCardViewController") as? FlashCardViewController)!
        
       self.navigationController?.pushViewController(flashCard, animated: true)
    }

}
