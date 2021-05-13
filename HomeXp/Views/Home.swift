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
    @State private var isEndOfList: Bool = false

    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var ivm = ItemViewModel()
    @StateObject var pvm = PieChartViewModel()

    var body: some View {
        ScrollViewReader { index in
        VStack {
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(alignment: .leading, spacing: -20) {
                    ForEach(items) { item in
                        let itno = items.lastIndex(of: item)!
                        ItemView(itno: items.lastIndex(of: item) ?? 0, item: item)
                            .id(itno)
                        .padding()
                        .contextMenu {
                            Button(action: {
                                summaryItem = item
                                showSummary = true
                            }, label: {
                                 Text("Amount")
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
                trailing: 
            	HStack {
		    Button(action: {
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
                                        Button(action: {
                                            isEndOfList.toggle()
                                            withAnimation {
                                                index.scrollTo(isEndOfList ? items.count-1 : 0)
                                            }
                                        }, label: {
                                            Image(systemName: "arrow.down.circle")
                                                .font(.title)
                                                .rotationEffect(.degrees(isEndOfList ? 180 : 0))
                                                .animation(.spring())
                                        })
                                    } // HStack
            )
            .alert(isPresented: $showSummary) {
                Alert(title:Text(String(format: "Amount: %5.1f", self.summaryItem.quantity*self.summaryItem.rate)),
                          message: Text(String(format: "(quantity %g,", self.summaryItem.quantity)) + Text(String(format: " rate %3.f)", self.summaryItem.rate)),
                          dismissButton: .default(Text("Cancel")))
            }
            if(items.isEmpty) {
                Text("No items found!!").font(.caption).foregroundColor(.red).fontWeight(.bold)
            } else {
                Text("Rs. \(SumOf(items: self.items), specifier: "%5.0f")").font(.caption).foregroundColor(.red).fontWeight(.bold)
                Text("\(CountOf(items: self.items)) \(UnitOf(value: self.items.last!.title!)), \(items.count) txns").font(.caption).fontWeight(.bold)
            }
            Spacer()
                Text("©2020 Home 13.0, G. R. Akhtar, Islamabad.").font(.caption).foregroundColor(.gray)
        }
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
        var names: [String]
    }
    
    func Compute() {
        let catagories: [Name] = [
            Name(id: 0, names: ["Bricks"]),
            Name(id: 1, names: ["Cement"]),
            Name(id: 2, names: ["Crush", "Sand"]),
            Name(id: 3, names: ["Electric", "Lights", "Sheets", "Akbar"]),
            Name(id: 4, names: ["Hakim"]),
            Name(id: 5, names: ["Marble"]),
            Name(id: 6, names: ["Paint", "Wajid"]),
            Name(id: 7, names: ["Steel"]),
            Name(id: 8, names: ["Tile"]),
            Name(id: 9, names: ["Windows", "Grill"]),
            Name(id:10, names: ["Door", "Cupboard"])
        ]

        var total: Float = 0
        var cats = [String]()
        var budgets = [Double]()
        
        for catagory in catagories {
            var budget: Float = 0
            for name in catagory.names {
                let its = aitems.filter { $0.title!.lowercased().contains(name.lowercased()) }
                budget += SumOf(items: its)
            }
            cats.append(catagory.names.first!)
            budgets.append(Double(budget))
            total += budget
        }
        
        let atotal = SumOf(items: self.items)
        cats.append("Others")
        budgets.append(Double(atotal-total))

        // Update above info to PieChart's View Model
        pvm.updateData(tags: cats, values: budgets, total: Double(atotal))
    }
}
