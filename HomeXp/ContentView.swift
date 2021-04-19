//
//  ContentView.swift
//  HomeXp
//
//  Created by Home on 3/28/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: true)], animation: .default)
    private var allItems: FetchedResults<Item>
    @State var filteredItems = [Item]()

    var body: some View {
        CustomNavigationView(view: Home(aitems: allItems, items: $filteredItems), onSearch: { (txt) in
            if txt == "" {
                self.filteredItems = allItems.compactMap( { $0 } )
            }
            else {
                let parts = txt.components(separatedBy: ":")
                if parts.count > 1 {
                    let title = parts[0], suplr = parts[1]
                    self.filteredItems = allItems.filter {
                        ($0.title!.lowercased().contains(title.lowercased()) && $0.supplier!.lowercased().contains(suplr.lowercased()))
                    }
                    if self.filteredItems.isEmpty {
                        self.filteredItems = allItems.filter {
                            ($0.title!.lowercased().contains(suplr.lowercased()) && $0.supplier!.lowercased().contains(title.lowercased()))
                        }
                    }
                } else {
                    self.filteredItems = allItems.filter {
                        ($0.title!.lowercased().contains(txt.lowercased()))
                    }
                    if self.filteredItems.isEmpty {
                        self.filteredItems = allItems.filter {
                            ($0.supplier!.lowercased().contains(txt.lowercased()))
                        }
                    }
                }
                
                if self.filteredItems.isEmpty {
                    let amount = Int(txt) ?? 0
                    if(amount > 1000) {
                        self.filteredItems = allItems.filter {
                            ($0.quantity*$0.rate >= Float(amount))
                        }
                    }
                }
            }
        }, onCancel: {
            self.filteredItems = allItems.compactMap( { $0 } )
        })
        .onAppear(perform: {
            self.filteredItems = allItems.compactMap( { $0 } )
        })
        .onChange(of: allItems.count, perform: { _ in
            self.filteredItems = allItems.compactMap( { $0 } )
        })
        .ignoresSafeArea()
    }
}
