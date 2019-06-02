//
//  AutocompleteHandler.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-28.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit
import MapKit

class AutocompleteHandler: NSObject, UITextFieldDelegate {
    
    let completer = MKLocalSearchCompleter()
    weak var delegate: AutocompleteDelegate?
    weak var table: HandlerDelegate?
    
    init(delegate: AutocompleteDelegate, table: HandlerDelegate) {
        self.delegate = delegate
        self.table = table
        super.init()
        completer.delegate = self
        completer.filterType = .locationsOnly
    }
    
    // MARK: - UITextField Delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchFirstResult()
        return true
    }
    
    func searchFirstResult() {
        delegate?.filterCityAndCheckWeather(for: table?.firstAutocompleteResult ?? "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        startCompleter()
        return true
    }
}

extension AutocompleteHandler: MKLocalSearchCompleterDelegate {
    
    func startCompleter() {
        completer.queryFragment = delegate?.cityField.text ?? ""
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results.filter {
            let rangeOfDigits = $0.subtitle.rangeOfCharacter(from: .decimalDigits)
            return rangeOfDigits == nil
            }.map { $0.title }
        table?.updateTable(with: results)
    }
}
