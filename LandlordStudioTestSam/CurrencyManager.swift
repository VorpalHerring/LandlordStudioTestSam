//
//  CurrencyManager.swift
//  LandlordStudioTestSam
//
//  Created by Samuel Moriyasu on 24/09/20.
//

import UIKit
import SwiftyJSON


extension Notification.Name
{
    static let baseMultiplierChanged = Notification.Name("didReceiveData")
}

class CurrencyManager: NSObject
{
    static let shared = CurrencyManager();
    static var count : Int
    {
        return CurrencyManager.shared.currencyList.count;
    }
    
    var currencyList : [String:Currency] = [:];
    var defaultOrdering : [String] = [];
    
    var baseMultiplier : Double = 1.0
    {
        didSet
        {
            if oldValue != baseMultiplier
            {
                NotificationCenter.default.post(name: .baseMultiplierChanged, object: nil);
            }
        }
    }
    
    var timer : Timer = Timer();
    
    func startPolling(fetchComplete: @escaping() -> Void)
    {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.fetchCurrencyList {
                fetchComplete();
            }
        })
    }
    
    func fetchCurrencyList(completionHandler: @escaping() -> Void)
    {
        guard let fetchURL = URL(string: "https://revolut.duckdns.org/latest?base=EUR") else
        {
            print("Currency List Unavailable")
            return
        };
        var request = URLRequest(url: fetchURL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSON(data: data!);
                self.parseCurrency(json: json);
                //print(json)
            } catch {
                print("error")
            }
            DispatchQueue.main.async {
                completionHandler();
            }
        })

        task.resume()
    }
    
    func parseCurrency(json : JSON)
    {
        var newDefaultOrdering : [String] = [];
        var newCurrencyList : [String:Currency] = [:]
        let baseCurrency = Currency(code: json["base"].string ?? "EUR", rate: 1.0);
        newCurrencyList[baseCurrency.currencyCode] = baseCurrency;
        
        guard let rates = json["rates"].dictionaryObject as? [String:Double] else
        {
            print("Invalid rates format");
            return;
        }
        for (code, rate) in rates
        {
            newDefaultOrdering.append(code);
            newCurrencyList[code] = Currency(code: code, rate: rate);
            //print(code, rate);
        }
        newDefaultOrdering.sort();
        newDefaultOrdering.insert(baseCurrency.currencyCode, at: 0);
        
        self.currencyList = newCurrencyList;
        self.defaultOrdering = newDefaultOrdering;
    }
}
