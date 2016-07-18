//
//  BackFlashCardViewModel.swift
//  GRE
//
//  Created by Mr.Vu on 7/9/16.
//  Copyright © 2016 Mr.Vu. All rights reserved.
//

import UIKit
import Spring
import RxCocoa
import RxSwift

class BackFlashCardViewModel: SpringView {

    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var lblWord: UILabel!
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblScript: UILabel!
    @IBOutlet weak var btnKnew: UIButton!
    @IBOutlet weak var btnNotKnew: UIButton!
    @IBOutlet weak var vTag: UIView!

    var height : CGFloat = 0
    var card : Card! {
        didSet{
            self.layout()
        }
    }
    
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.grayColor().CGColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSizeZero
        self.layer.shadowRadius = 5
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        self.lblWord.text   = self.card.word
        self.lblTag.text    = self.card.tag.uppercaseString
        self.lblType.text   = self.card.type
        self.lblScript.text = self.card.script
        
        if card.tag == NEW_WORD_TAG {
            self.vTag.backgroundColor = NEW_WORD_TAG_COLOR
        }
        else if card.tag == LEARNING_TAG {
            self.vTag.backgroundColor = LEARNING_TAG_COLOR
        }
        else if card.tag == REVIEW_TAG {
            self.vTag.backgroundColor = REVIEW_TAG_COLOR
        }
        else if card.tag == MASTER_TAG {
            self.vTag.backgroundColor = MASTER_TAG_COLOR
        }

       updateLayout()
        
    }
    func updateLayout(){
        self.layoutIfNeeded()
        self.lblWord.layoutIfNeeded()
        self.lblTag.layoutIfNeeded()
        self.lblType.layoutIfNeeded()
        self.lblScript.layoutIfNeeded()
    
        self.lblScript.sizeToFit()
        self.lblType.sizeToFit()
        self.lblWord.sizeToFit()
        self.height = self.lblWord.frame.size.height + self.lblType.frame.size.height
            + self.lblScript.frame.size.height + 60
        print(self.bounds.size.height/3)
    }

}
