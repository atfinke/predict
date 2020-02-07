//
//  Model.swift
//  predict
//
//  Created by Andrew Finke on 2/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation

struct PredictResponse: Decodable {
    let markets: [Market]
}

struct Market: Decodable, Identifiable, Hashable, Equatable {
    static func == (lhs: Market, rhs: Market) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    enum Status: String, Decodable {
        case open = "Open"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, shortName, url, status, contracts
        case lastUpdated = "timeStamp"
    }
    
    let id: Int
    let name: String
    let shortName: String
    let url: String
    
    let status: Status
    let lastUpdated: Date
    
    let contracts: [Contract]
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
    
    
}

struct Contract: Decodable, Identifiable {
    let id: Int
    let name: String
    let shortName: String
    
    let lastTradePrice: Double?
    let bestBuyYesCost: Double?
    let bestBuyNoCost: Double?
    let bestSellYesCost: Double?
    let bestSellNoCost: Double?
    let lastClosePrice: Double?
}


struct Model {
    
    let markets: [Market]
    
    init() {
        let urlString = "https://www.predictit.org/api/marketdata/all/"
        guard let url = URL(string: urlString) else { fatalError() }

        let temp = NSTemporaryDirectory()
        let path = temp + "predict"
        let fileURL = URL(fileURLWithPath: path)
        print(fileURL)

        do {
            var _data = try? Data(contentsOf: fileURL)
            if _data == nil {
                _data = try Data(contentsOf: url)
            }
            guard let data = _data else { fatalError() }
            try data.write(to: fileURL)

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(formatter)
            let response = try decoder.decode(PredictResponse.self, from: data)

            self.markets = response.markets
        } catch {
            fatalError(error.localizedDescription)
        }
    }

}
