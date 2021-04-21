//
//  CasesTableViewCell.swift
//  Corona Data Muncher iOS
//
//  Created by Colin Wilson on 06/10/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import UIKit

class CasesTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var casesLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var dataInfo: DataInfo? {
        didSet {
            guard let info = dataInfo else {
                dateLabel.text = "-"
                casesLabel.text = "-"
                return
            }
            dateLabel.text = DateFormatter.localizedString(from: info.date, dateStyle: .short, timeStyle: .none)
            if let cases = info.newCases {
                casesLabel.text = String (cases)
            } else {
                casesLabel.text = "-"
            }
        }
    }

}
