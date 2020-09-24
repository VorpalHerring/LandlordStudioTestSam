//
//  ViewController.swift
//  LandlordStudioTestSam
//
//  Created by Samuel Moriyasu on 24/09/20.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var ordering : [String] = [];
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        CurrencyManager.shared.fetchCurrencyList
        {
            self.spinner.stopAnimating();
            self.ordering = Array(CurrencyManager.shared.defaultOrdering);
            self.tableView.reloadSections(IndexSet(0...0), with:.automatic);
            
            CurrencyManager.shared.startPolling
            { [unowned self] in
                updateVisibleRates();
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateVisibleRates), name: .baseMultiplierChanged, object: nil);
    }
    
    @objc func updateVisibleRates()
    {
        self.tableView.visibleCells.compactMap{$0 as? CurrencyTableViewCell}.forEach
        { (cell) in
            cell.updateRate();
        }
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ordering.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyTableViewCell;
            
        let key = self.ordering[indexPath.row];
        if let currency = CurrencyManager.shared.currencyList[key]
        {
            cell.configure(currency);
            cell.setAtTop(atTop: false);
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false);
        if let topCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CurrencyTableViewCell
        {
            topCell.setAtTop(atTop: false);
        }
        self.tableView.beginUpdates();
        let codeToMove = self.ordering[indexPath.row];
        self.ordering.remove(at: indexPath.row);
        self.ordering.insert(codeToMove, at: 0);
        self.tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0));
        self.tableView.endUpdates();
        self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true);
        if let topCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CurrencyTableViewCell
        {
            topCell.setAtTop(atTop: true);
        }
    }
}

