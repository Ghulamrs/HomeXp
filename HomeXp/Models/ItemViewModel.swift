//
//  ItemViewModel.swift
//  HomeXp
//
//  Created by Home on 3/28/21.
//

import Foundation
import CoreData

struct Title: Hashable, Identifiable {
    var id: Int
    var name: String
    var unit: String
}

class ItemViewModel: ObservableObject {
    var date = Date()
    @Published var title:    String = ""
    @Published var supplier: String = ""
    @Published var quantity: String = ""
    @Published var rate:     String = ""
    @Published var tIndex:   Int = 0
    @Published var uIndex:   Int = 0

    let titles: [Title] = [
        Title(id: 0, name: "Select",     unit: "unit"),
        Title(id: 1, name: "Bricks",     unit: "k"),
        Title(id: 2, name: "Cement",     unit: "bag"),
        Title(id: 3, name: "Crush",      unit: "dumper"),
        Title(id: 4, name: "Sand",       unit: "dumper"),
        Title(id: 5, name: "Steel rods", unit: "ton"),
        Title(id: 6, name: "Marble",     unit: "sq-ft"),
        Title(id: 7, name: "Paint",      unit: "bucket"),
        Title(id: 8, name: "Pipes/Electric", unit: "feet"),
        Title(id: 9, name: "Tile",       unit: "sq-m"),
        Title(id:10, name: "Windows",    unit: "rupee"),
        Title(id:11, name: "Wood",       unit: "meter")
    ]
    var updateItem: Item!

    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        self.date = Date()
    }
    
    func populate(item: Item) {
        updateItem  = item
        self.title  = item.title!
        self.tIndex = titles.compactMap{ $0.name }.firstIndex(of: item.title!) ?? 0
        self.uIndex = titles.compactMap{ $0.unit }.unique().firstIndex(of: item.unit!) ?? 0
        self.supplier = item.supplier!
        self.quantity = String(item.quantity)
        self.rate   = String(item.rate)
        self.date   = item.date!
    }
    
    func findunit(value title: String) -> String? {
        let titlez = titles.compactMap{ $0.name }
        if(titlez.contains(title)) {
            for (index, value) in titlez.enumerated() {
                if value == title {
                    return titles[index].unit
                }
            }
        }
        return nil
    }
    
    func reset() {
        title  = ""
        supplier = ""
        quantity = ""
        rate = ""
        
        uIndex = 0
        tIndex = 0
    }
}
