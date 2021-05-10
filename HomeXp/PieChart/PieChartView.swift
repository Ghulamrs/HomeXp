//
//  PieChartView.swift
//  HomeXp
//
//  Updated by Home on 4/9/21.
//  All PieChart source used in this project is
//  taken from Kent Winder with his copyright notice.
//
//  Originally Created by Kent Winder on 3/17/20.
//  Copyright © 2020 Nextzy. All rights reserved.
//

import Foundation
import SwiftUI

struct PieChartView: View {
    @ObservedObject var viewModel: PieChartViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Spacer()
                PieChart(pieChartData: self.viewModel.pieChartData)
                    .frame(width: geometry.size.width,
                           height: geometry.size.width)
                Spacer()
                Text("Rs \(viewModel.totalExpenditure, specifier: "%5.0f") Catagory vise Distribution")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                    .background(Color(red: 1, green: 0.5, blue: 0.5))
                    .cornerRadius(20)
                Spacer()
                Text("©2020 Home 12.0, G. R. Akhtar, Islamabad.").font(.caption).foregroundColor(.gray)
            }
        }.padding()
    }
}
