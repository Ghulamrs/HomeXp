//
//  Home.swift
//  Home
//
//  Created by Home on 1/7/21.
//

import SwiftUI
import CoreData

struct Home: View {
    var aitems: FetchedResults<Item>
    @Binding var items: [Item]
    
    @State private var summaryItem = Item()
    @State private var showSummary: Bool = false
    @State private var isPresented: Bool = false
    @State private var isPiePresented: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var ivm = ItemViewModel()
    @StateObject var pvm = PieChartViewModel()

    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(alignment: .leading, spacing: -20) {
                    ForEach(items) { item in
                        ItemView(itno: items.lastIndex(of: item) ?? 0, item: item)
                        .padding()
                        .contextMenu {
                            Button(action: {
                                summaryItem = item
                                showSummary = true
                            }, label: {
                                 Text("Summary")
                            })
                            Button(action: {
                                if items.count == aitems.count {
                                    ivm.populate(item: item)
                                    viewContext.delete(item)
                                    isPresented.toggle()
                                }
                            }, label: {
                                 Text("Update")
                            })
                            Divider()
                            Button(action: {
                                for item in items {
                                    if(item.title == nil) {
                                        viewContext.delete(item)
                                        saveContext()
                                    }
                                }
                            }, label: {
                                 Text("Clean")
                            })
                            Button(action: {
                                 viewContext.delete(item)
                                 saveContext()
                            }, label: {
                                Text("Delete").foregroundColor(.red)
                            })
                        }
                    }
                }
            })
            .navigationTitle("HomeXp")
            .navigationBarItems(
                leading: Button(action: {
                    Compute()
                    isPiePresented = true
                }, label: {
                    Image(systemName: "house")
                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.2))
                        .font(.title)
                })
                .sheet(isPresented: $isPiePresented, onDismiss: {
                }) {
                    PieChartView(viewModel: pvm)
                },
                trailing: Button(action: {
                        ivm.title.removeAll()
                        isPresented = true
                    }, label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.purple)
                            .font(.title)
                    })
                    .sheet(isPresented: $isPresented, onDismiss: {
                    }) {
                        AddItemView(itemViewModel: ivm)
                    }
            )
            .alert(isPresented: $showSummary) {
                Alert(title:Text(String(format: "Amount: %5.1f", self.summaryItem.quantity*self.summaryItem.rate)),
                          message: Text(String(format: "qty %1.f", self.summaryItem.quantity)) + Text(String(format: " rate %4.f", self.summaryItem.rate)),
                          dismissButton: .default(Text("Cancel")))
            }
            if(items.isEmpty) {
                Text("No items found!!").font(.caption).foregroundColor(.red).fontWeight(.bold)
            } else {
                Text("Rs. \(SumOf(items: self.items), specifier: "%5.0f")").font(.caption).foregroundColor(.red).fontWeight(.bold)
                Text("\(CountOf(items: self.items)) \(UnitOf(value: self.items.last!.title!)), \(items.count) txns").font(.caption).fontWeight(.bold)
            }
            Spacer()
            Text("©2020 Home 11.0, G. R. Akhtar, Islamabad.").font(.caption).foregroundColor(.gray)
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved error: \(error)")
        }
    }
    
    func CountOf(items: [Item]) -> Int32 {
        var total: Float = 0
        for item in items {
            if(item.title != nil) {
                total += item.quantity
            }
        }
        return Int32(total)
    }

    func SumOf(items: [Item]) -> Float {
        var total: Float = 0
        for item in items {
            if(item.title != nil) {
                total += item.rate*item.quantity
            }
        }
        return total
    }

    func UnitOf(value title: String) -> String {
        let it = ItemViewModel()
        return it.findunit(value: title) ?? "units"
    }

    struct Name: Hashable, Identifiable {
        var id: Int
        var name: String
    }
    
    func Compute() {
        let catagory: [Name] = [
            Name(id: 0, name: "Bricks"),
            Name(id: 1, name: "Cement"),
            Name(id: 2, name: "Crush"),
            Name(id: 3, name: "Electric"),
            Name(id: 4, name: "Hakim"),
            Name(id: 5, name: "Marble"),
            Name(id: 6, name: "Paint"),
            Name(id: 7, name: "Steel"),
            Name(id: 8, name: "Tile"),
            Name(id: 9, name: "Windows"),
            Name(id:10, name: "Others")
        ]

        var cats = [String]()
        var budgets = [Double]()
        var all = SumOf(items: self.items)

        for cat in catagory {
            let its = aitems.filter {
                ($0.title!.lowercased().contains(cat.name.lowercased()))
            }
            cats.append(cat.name)
            if cat.name == "Others" {
                budgets.append(Double(all))
            } else {
                let bud = SumOf(items: its)
                budgets.append(Double(bud))
                all -= bud
            }
        }
        
        // Add 'Lights' items expenses to Electric catagory
        let its = aitems.filter {
            ($0.title!.lowercased().contains("lights"))
        }
        let catagoryIndex = cats.firstIndex(of: "Electric")
        if  catagoryIndex != nil {
            let index: Int = catagoryIndex!
            if  index < budgets.count {
                budgets[index] += Double(SumOf(items: its))
            }
        }
        // Update above info to Pie Chart View Model class
        pvm.updateData(tags: cats, values: budgets)
    }
}
