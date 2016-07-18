//
//  FrontFlashCardViewModel.swift
//  GRE
//
//  Created by Mr.Vu on 7/9/16.
//  Copyright © 2016 Mr.Vu. All rights reserved.
//

import UIKit
import Spring

class FrontFlashCardViewModel: SpringView {
    
    @IBOutlet weak var imvPokemon: UIImageView!
    var pokemon : Pokemon! {
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
    
    func layout() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
