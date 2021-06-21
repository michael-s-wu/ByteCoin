//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Michael Wu on 04/28/2020.
//  Copyright © 2020 Michael Wu. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    //Create the method stubs wihtout implementation in the protocol.
    //It's usually a good idea to also pass along a reference to the current class.
    //e.g. func didUpdatePrice(_ coinManager: CoinManager, price: String, currency: String)
    //Check the Clima module for more info on this.
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    let apiKey = "1484F523-C304-440F-8A77-6392B16F6575"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        
        let urlString = baseURL + currency + "?apikey=" + apiKey
        
        //Use optional binding to unwrap the URL that's created from the urlString
        if let url = URL(string: urlString) {
            
            //Create a new URLSession object with default configuration.
            let session = URLSession(configuration: .default)
            
            //Create a new data task for the URLSession
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                //Format the data we got back as a string to be able to print it.
                if let safeData = data {
                    if let bitcoinPrice = self.parseJSON(safeData) {
                        //Optional: round the price down to 2 decimal places.
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        
                        //Call the delegate method in the delegate (ViewController) and
                        //pass along the necessary data.
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
                
            }
            //Start task to fetch data from bitcoin average's servers.
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        
        //Create a JSONDecoder
        let decoder = JSONDecoder()
        do {
            
            //try to decode the data using the CoinData structure
            let decodedData = try decoder.decode(CoinData.self, from: data)
            
            //Get the last property from the decoded data.
            let lastPrice = decodedData.rate
            return lastPrice
            
        } catch {
            
            //Catch and print any errors.
            print(error)
            return nil
        }
    }
    
    
   
    
    
}
