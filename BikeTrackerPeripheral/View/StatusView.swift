//
//  StatusView.swift
//  BikeTracker
//
//  Created by Uday Pandey on 06/05/2020.
//  Copyright © 2020 Uday Pandey. All rights reserved.
//

import UIKit

@IBDesignable
class StatusView: UIView {
    @IBOutlet weak var detailedTextLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    
    var contentView: UIView?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    private func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view

        self.layer.borderWidth = 1
        self.backgroundColor = UIColor.init(red: 245/255.0,
                                            green: 245/255.0,
                                            blue: 245/255.0, alpha: 1.0)
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        self.layer.cornerRadius = 10

    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "StatusView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

}
