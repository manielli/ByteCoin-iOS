//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(_ coinManager: CoinManager, coinPrice: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "B34FE8B1-1AC3-4448-B82B-0C36E6A2DA98"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    var delegate: CoinManagerDelegate?

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apiKey=B34FE8B1-1AC3-4448-B82B-0C36E6A2DA98"
//        let urlString = "\(baseURL)/\(currency)"
        
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            
//            var request = URLRequest(url: url)
//            request.setValue(apiKey, forHTTPHeaderField: "X-CoinAPI-Key")
            let session = URLSession(configuration: .default)

//            let task = session.dataTask(with: request) { data, response, error in
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let coinData = parseJSON(safeData) {
                        delegate?.didUpdatePrice(self, coinPrice: coinData)
                    }
                    
                }
            }

            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate
            let currency = decodedData.asset_id_quote
            let coinData = CoinModel(price: rate, currency: currency)
            
            return coinData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
