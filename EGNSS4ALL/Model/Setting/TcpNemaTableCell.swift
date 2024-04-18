//
//  TcpNemaTableCell.swift
//  EGNSS4ALL
//
//  Created by Asit Mac on 15/04/24.
//

import UIKit

class TcpNemaTableCell: UITableViewCell {
    
    
    @IBOutlet weak var tcpSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
