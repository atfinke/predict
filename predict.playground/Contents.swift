import Cocoa

let urlString = "https://www.predictit.org/api/marketdata/all/"
guard let url = URL(string: urlString) else { fatalError() }

struct PredictResponse: Decodable {
    let markets: [Market]
}

struct Market: Decodable {
    
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
}

struct Contract: Decodable {
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

    for market in response.markets {
        print(market.name + " (\(market.id)) - \(market.lastUpdated)")
        for contract in market.contracts {
            print("     \(contract.name)")
            print("     - yes: \(contract.bestBuyYesCost?.description ?? "N/A"), no: \(contract.bestBuyNoCost?.description ?? "N/A")")
        }
    }
} catch {
    fatalError(error.localizedDescription)
}

