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
    @Published var pieChartData = PieChartData(name: [String](), data: [Double]())
    
    func updateData(tags: [String], values: [Double]) {
        pieChartData = PieChartData(name: [String](), data: [Double]())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.pieChartData = PieChartData(name: tags, data: values)
        }
    }
}
