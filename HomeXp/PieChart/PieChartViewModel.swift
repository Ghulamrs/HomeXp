//
//  PieChartViewModel.swift
//  HomeXp
//
//  Created by Kent Winder on 3/17/20.
//  Copyright © 2020 Nextzy. All rights reserved.
//

import Combine
import Foundation

class PieChartViewModel: ObservableObject {
    let persistenceController = PersistenceController.shared
    @Published var pieChartData = PieChartData(name: [String](), data: [Double]())
    @Published var totalExpenditure = 0.0

    func updateData(tags: [String], values: [Double], total: Double) {
        pieChartData = PieChartData(name: [String](), data: [Double]())
        totalExpenditure = total
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.pieChartData = PieChartData(name: tags, data: values)
        }
    }
}
