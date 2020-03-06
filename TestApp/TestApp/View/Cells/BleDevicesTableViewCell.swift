//
//  BleDevicesTableViewCell.swift
//  TestApp
//
//  Created by Булат Сунгатуллин on 06.03.2020.
//  Copyright © 2020 Булат Сунгатуллин. All rights reserved.
//

import UIKit

class BleDevicesTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var powerDeviceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
