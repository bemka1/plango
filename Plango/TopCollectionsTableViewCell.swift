//
//  TopCollectionsTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/14/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class TopCollectionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImageView: CompoundImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var plansCountLabel: UILabel!
    
    var plangoCollection: PlangoCollection?
    var plans: [Plan]?
    
    func configure() {
        self.layoutIfNeeded()
        if let avatarString = plangoCollection?.avatar {
            let avatarURL = URL(string: Plango.sharedInstance.cleanEndPoint(avatarString))

            coverImageView.af_setImage(withURL: avatarURL!)
            coverImageView.gradientDarkToClear()
        }
        
        titleLabel.text = plangoCollection?.name
        
        if let plansCount = plans?.count {
            if plansCount > 1 {
                plansCountLabel.text = "\(plansCount) Plans"
            } else {
                plansCountLabel.text = "\(plansCount) Plan"
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let cover = coverImageView else {return}
        cover.af_cancelImageRequest()
        cover.layer.sublayers?.removeLast()
    }

}

class TopCollectionsMiddleTableViewCell: TopCollectionsTableViewCell {
    @IBOutlet weak var coverImageViewM: UIImageView!
    @IBOutlet weak var titleLabelM: UILabel!
    @IBOutlet weak var plansCountLabelM: UILabel!
    
    
    override func configure() {
        self.layoutIfNeeded()
        if let avatarString = plangoCollection?.avatar {
            let avatarURL = URL(string: Plango.sharedInstance.cleanEndPoint(avatarString))
            coverImageViewM.af_setImage(withURL: avatarURL!)
            
        }
        
        titleLabelM.text = plangoCollection?.name
        
        if let plansCount = plans?.count {
            if plansCount > 1 {
                plansCountLabelM.text = "\(plansCount) Plans"
            } else {
                plansCountLabelM.text = "\(plansCount) Plan"
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        coverImageViewM.af_cancelImageRequest()
    }
}
