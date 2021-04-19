//
//  AddItemView.swift
//  HomeXp
//
//  Created by Home on 3/28/21.
//

import SwiftUI
import CoreData

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var itemViewModel: ItemViewModel

    var body: some View {
        VStack {
            Picker(selection: $itemViewModel.tIndex, label: Text("\(itemViewModel.titles[itemViewModel.tIndex].name)")) {
                ForEach(0 ..< itemViewModel.titles.count) {
                    Text(self.itemViewModel.titles[$0].name)
                }
            }
            .onChange(of: itemViewModel.tIndex, perform: { value in
                itemViewModel.title = itemViewModel.titles[itemViewModel.tIndex].name
                let sunit = itemViewModel.titles[itemViewModel.tIndex].unit
                let units = itemViewModel.titles.compactMap{ $0.unit }.unique()
                itemViewModel.uIndex = (units.firstIndex(of: sunit))!
            })
            .pickerStyle(MenuPickerStyle())
            TextField("title",    text: $itemViewModel.title).foregroundColor(.blue)
            TextField("supplier", text: $itemViewModel.supplier)
            TextField("quantity", text: $itemViewModel.quantity).foregroundColor(.red)
            TextField("rate",     text: $itemViewModel.rate)
            Picker(selection: $itemViewModel.uIndex, label: Text("Units")) {
                let units = itemViewModel.titles.compactMap{ $0.unit }.unique()
                ForEach(0 ..< units.count) {
                    Text(units[$0])
                }
            }
            .pickerStyle(WheelPickerStyle())
            DatePicker("", selection: $itemViewModel.date, displayedComponents: .date).labelsHidden()
        }
        .padding()
        
        HStack {
            Button((itemViewModel.title.isEmpty || itemViewModel.title=="Select") ? "Add Now" : "Update") {
                if(itemViewModel.title.isEmpty) { addItem() }
                else {
                    updateItem()
                }
                self.presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.green)
            .padding()
            Button("Cancel") {
                itemViewModel.reset()
                if(itemViewModel.updateItem != nil) { cancelItem() }
                self.presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.red)
        }
    }
    
    func saveContext() {
//      if viewContext.hasChanges {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved error: \(error)")
        }
  //    }
    }

    private func addItem() {
        withAnimation {
            let units = itemViewModel.titles.compactMap{ $0.unit }.unique()
            let AsEntered = itemViewModel.titles[itemViewModel.tIndex].name=="Select" ? true : false
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.title = AsEntered ? itemViewModel.title : itemViewModel.titles[itemViewModel.tIndex].name
            newItem.supplier = itemViewModel.supplier
            newItem.date = itemViewModel.date
            newItem.rate = Float(itemViewModel.rate) ?? 0
            newItem.quantity = Float(itemViewModel.quantity) ?? 1.0
            newItem.unit = AsEntered ? "" : units[itemViewModel.uIndex]

            itemViewModel.reset()
            saveContext()
        }
    }

    private func updateItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.title = itemViewModel.tIndex==0 ? itemViewModel.title : itemViewModel.titles[itemViewModel.tIndex].name
            newItem.supplier = itemViewModel.supplier
            newItem.date = itemViewModel.date
            newItem.rate = Float(itemViewModel.rate) ?? 0
            newItem.quantity = Float(itemViewModel.quantity) ?? 1.0
            let units = itemViewModel.titles.compactMap{ $0.unit }.unique()
            newItem.unit = units[itemViewModel.uIndex]

            itemViewModel.reset()
            saveContext()
        }
    }
    
    private func cancelItem() {
        withAnimation {
            let item = Item(context: viewContext)
            item.id = itemViewModel.updateItem.id
            item.title = itemViewModel.updateItem.title
            item.supplier = itemViewModel.updateItem.supplier
            item.date = itemViewModel.updateItem.date
            item.rate = itemViewModel.updateItem.rate
            item.quantity = itemViewModel.updateItem.quantity
            item.unit = itemViewModel.updateItem.unit

            itemViewModel.reset()
            saveContext()
        }
    }
    
    private func deleteItem(item: Item) {
        viewContext.delete(item)
        saveContext()
    }
}
