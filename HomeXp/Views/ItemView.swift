//
//  ItemView.swift
//  HomeXp
//
//  Created by Home on 3/28/21.
//
//

import SwiftUI

struct ItemView: View {
    var itno: Int
    var item: Item
    var body: some View {
        VStack(alignment: .leading, content: {
            Text("\((item.date ?? Date()), formatter: itemFormatter)").font(.caption).foregroundColor(.purple)
            HStack {
                Text("\(itno+1).")
                if item.quantity==1 { Text("\(item.title!) ... \(item.unit!)") }
                else {
                    Text("\(item.title ?? "Unknown") ... \(item.quantity, specifier: (item.quantity==floor(item.quantity) ? "%1.0f" : "%g")) \(item.unit ?? "unit")")
                }
            }
            Text("@\(item.rate, specifier: "%1.0f") by \(item.supplier ?? "Unknown")")
                    .font(.system(size: 14.0)).fontWeight(.regular)
                    .frame(width: UIScreen.main.bounds.width-40, height: 15, alignment: .trailing)
            Divider()
        })
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()
