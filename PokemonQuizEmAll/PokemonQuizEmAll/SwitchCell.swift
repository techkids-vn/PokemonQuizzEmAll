//
//  SwitchCell.swift
//  GRE
//
//  Created by Do Ngoc Trinh on 7/13/16.
//  Copyright © 2016 Mr.Vu. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnSwitch: UISwitch!
    
    let CELL_TYPE_SWITCH_SOUND : Int = 0
    let CELL_TYPE_SWITCH_MUSIC : Int = 1
    
    
    var typeCell: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.btnSwitch.onTintColor = THEME_COLOR
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    func setCellType(cellType: Int){
        typeCell = cellType
        if(typeCell == CELL_TYPE_SWITCH_SOUND){
            lblTitle.text = "Sound Effects"
            if(DB.getSoundOn()){
                self.btnSwitch .setOn(true, animated: false)
            }
            else{
                self.btnSwitch .setOn(false, animated: false)
            }
        }
        else
            if(typeCell == CELL_TYPE_SWITCH_MUSIC){
                lblTitle.text = "Music"
                if(DB.getMusicOn()){
                    self.btnSwitch .setOn(true, animated: false)
                }
                else{
                    self.btnSwitch .setOn(false, animated: false)
                }
        }
    }
    @IBAction func btnSwitch(sender: AnyObject) {
        if(btnSwitch.on == true){
            switch  typeCell{
            case CELL_TYPE_SWITCH_SOUND:
                turnOnSound()
                break
            case CELL_TYPE_SWITCH_MUSIC:
                turnOnMusic()
                break
            default:
                break
            }
        }
        else{
            switch  typeCell{
            case CELL_TYPE_SWITCH_SOUND:
                turnOffSound()
                break
            case CELL_TYPE_SWITCH_MUSIC:
                turnOffMusic()
                break
            default:
                break
            }
        }
    }
    
    func turnOffSound(){
        DB.updateSetting(1, turnOffMusic : -1)
    }
    
    func turnOnSound() {
        DB.updateSetting(0, turnOffMusic: -1)
    }
    
    func turnOnMusic() {
        DB.updateSetting(-1, turnOffMusic: 0)
    }
    
    func turnOffMusic() {
        DB.updateSetting(-1, turnOffMusic: 1)
    }
}
