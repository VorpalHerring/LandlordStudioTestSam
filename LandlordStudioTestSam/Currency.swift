//
//  Currency.swift
//  LandlordStudioTestSam
//
//  Created by Samuel Moriyasu on 24/09/20.
//

import UIKit

class Currency: NSObject
{
    var currencyCode : String = "EUR";
    var exchangeRateToEUR : Double = 1.0;
    
    var currencyName : String?
    {
        return Locale.current.localizedString(forCurrencyCode:self.currencyCode);
    }
    var flag : UIImage?
    {
        return UIImage.init(named: currencyCode.lowercased())
    }
    
    var multipliedRate : Double
    {
        return exchangeRateToEUR * CurrencyManager.shared.baseMultiplier;
    }
    
    func convertedMultiplier(newBaseMultiplier : Double) -> Double
    {
        if(self.exchangeRateToEUR == 0.0)
        {
            return 0.0;
        }
        return (1.0 / self.exchangeRateToEUR) * newBaseMultiplier;
    }
    
    init(code : String, rate : Double)
    {
        currencyCode = code;
        exchangeRateToEUR = rate;
    }
}
