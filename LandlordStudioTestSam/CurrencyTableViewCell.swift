//
//  CurrencyTableViewCell.swift
//  LandlordStudioTestSam
//
//  Created by Samuel Moriyasu on 24/09/20.
//

import UIKit

extension UIImageView
{
    func setRounded()
    {
        let radius = self.frame.width / 2;
        self.layer.cornerRadius = radius;
        self.layer.masksToBounds = true;
    }
}

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var currencyCodeLabel: UILabel!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var exchangeRateTextField: UITextField!
    
    var currency : Currency?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addDoneButtonOnKeyboard()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ currency: Currency)
    {
        self.currency = currency
        self.flagImageView.image = currency.flag;
        self.currencyCodeLabel.text = currency.currencyCode;
        self.currencyNameLabel.text = currency.currencyName;
        self.updateRate();
        self.flagImageView.setRounded();
    }
    
    func updateRate()
    {
        if (self.currency != nil)
        {
            self.currency = CurrencyManager.shared.currencyList[self.currency!.currencyCode];
            if (!self.exchangeRateTextField.isEditing)
            {
                let rateString = String(format: "%.2f", self.currency!.multipliedRate)
                self.exchangeRateTextField.text = rateString;
            }
            else
            {
                self.updateBaseMultiplier();
            }
        }
    }
    
    func setAtTop(atTop : Bool)
    {
        self.exchangeRateTextField.isUserInteractionEnabled = atTop;
        if(atTop)
        {
            self.exchangeRateTextField.becomeFirstResponder();
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any)
    {
        self.updateBaseMultiplier();
    }
    
    func updateBaseMultiplier()
    {
        if(currency != nil)
        {
            if let newMultiplier = Double(self.exchangeRateTextField.text ?? "0")
            {
                CurrencyManager.shared.baseMultiplier = self.currency!.convertedMultiplier(newBaseMultiplier:newMultiplier) ;
            }
            else
            {
                CurrencyManager.shared.baseMultiplier = 0.0;
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        exchangeRateTextField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction()
    {
        exchangeRateTextField.resignFirstResponder()
    }
}
