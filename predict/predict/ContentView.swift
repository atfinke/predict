//
//  ContentView.swift
//  predict
//
//  Created by Andrew Finke on 2/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SwiftUI

let model = Model()

struct ContentView: View {
    @State private var selectedMarket: Market?
    var body: some View {
        NavigationView {
            NavigationMaster(selectedMarket: $selectedMarket)
            
            if selectedMarket != nil {
                NavigationDetail(market: selectedMarket!)
            }
        }
        .frame(minWidth: 500, minHeight: 300)
    }
}

struct NavigationMaster: View {
    @Binding var selectedMarket: Market?
    var body: some View {
        VStack {
            MarketList(selectedMarket: $selectedMarket)
                .listStyle(SidebarListStyle())
        }
        .frame(minWidth: 250, maxWidth: 350)
    }
}

struct MarketList: View {
    @Binding var selectedMarket: Market?
    var body: some View {
        List(model.markets, id: \.self, selection: $selectedMarket) { market in
            HStack {
                Text(market.name)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.leading, 5)
                .padding([.top, .bottom], 20)
        }
    }
}


struct NavigationDetail: View {
    var market: Market
    
    var body: some View {
        ScrollView() {
            HStack {
                Text(market.name)
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .multilineTextAlignment(.leading)
                Spacer()
                Button(action: {
                    NSWorkspace.shared.open(URL(string: self.market.url)!)
                }) {
                    Text("Open")
                }
            }
            
            Spacer()
            
            ForEach(market.contracts) { contract in
                HStack {
                    if contract.name != self.market.name {
                    Text(contract.name).font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    Spacer()
                    
                    Text("Y: \(contract.bestBuyYesCost?.description ?? " N/A"), N: \(contract.bestBuyNoCost?.description ?? " N/A")")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                }
            }
            Spacer()
            
        }
        .padding()
            .frame(maxWidth: 600)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationMaster(selectedMarket: .constant(model.markets[0]))
    }
}
