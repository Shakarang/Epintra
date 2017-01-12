//
//  EventTableViewCell.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 10/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var activityTypeView: UIView!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var moduleTitleLabel: UILabel!
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    var activityColor: UIColor! = .black
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.activityTypeView.backgroundColor = self.activityColor
        
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.activityTypeView.backgroundColor = self.activityColor
    }
    
    func setView(with data: Planning) {
        
        if let eventType = data.eventType {
            self.activityColor = UIUtils.activitiesColors[eventType]
        }
        
        self.activityTitleLabel.text = data.actiTitle
        self.moduleTitleLabel.text = String(format: "%@ - %@", data.titleModule!, data.codeInstance!)
        
        self.startTimeLabel.text = data.startTime?.toEventHour()
        self.endTimeLabel.text = data.endTime?.toEventHour()
        
        self.setStatusImage(data: data)
    }
    
    func setStatusImage(data: Planning) {
        
        self.accessoryType = .none
        
        if (data.eventType == "rdv") {
            statusImageView.image = nil
            statusImageView.tintColor = UIUtils.planningGrayColor
            self.accessoryType = .disclosureIndicator
            return
        }
        
        if (data.canEnterToken()) {
            statusImageView.image = #imageLiteral(resourceName: "Token").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningBlueColor
        } else if (data.canRegister()) {
            statusImageView.image = #imageLiteral(resourceName: "Register").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningGreenColor
        } else if (data.canUnregister()) {
            statusImageView.image = #imageLiteral(resourceName: "Unregister").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningRedColor
        } else if (data.isRegistered() && !data.canUnregister()) {
            statusImageView.image = #imageLiteral(resourceName: "Unregister").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningGrayColor
        } else if (data.isUnregistered() && !data.canRegister()) {
            statusImageView.image = #imageLiteral(resourceName: "Register").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningGrayColor
        } else if (data.wasPresent()) {
            statusImageView.image = #imageLiteral(resourceName: "Done").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningGreenColor
        } else if (data.wasAbsent()) {
            statusImageView.image = #imageLiteral(resourceName: "Delete").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningRedColor
        } else {
            statusImageView.image = nil
        }
    }
}