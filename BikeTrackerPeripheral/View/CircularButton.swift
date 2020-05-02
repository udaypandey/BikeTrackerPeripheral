//
//  CircularButton.swift
//  BikeTracker
//
//  Created by Uday Pandey on 06/05/2020.
//  Copyright © 2020 Uday Pandey. All rights reserved.
//

import UIKit

class CircularButton: UIButton {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.layer.borderWidth = 3
        self.backgroundColor = .white
        
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        
        self.setTitleColor(.black, for: .normal)
        self.setTitleColor(.lightGray, for: .disabled)
        
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
        
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .orange : .white
            if isHighlighted {
                setTitleColor(.white, for: .normal)
            } else {
                setTitleColor(.black, for: .normal)
            }
        }
    }

    override open var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.layer.borderColor = UIColor.orange.cgColor
            } else {
                let colorValue: CGFloat = 220.0
                let borderColor = UIColor.init(red: colorValue/255.0,
                                                    green: colorValue/255.0,
                                                    blue: colorValue/255.0, alpha: 1.0)

                layer.borderColor = borderColor.cgColor
            }
        }
    }

}
