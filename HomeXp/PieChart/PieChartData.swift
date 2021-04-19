//
//  PieChartData.swift
//  HomeXp
//
//  Updated by Home on 4/9/21.
//
//  Created by Kent Winder on 3/17/20.
//  Copyright © 2020 Nextzy. All rights reserved.
//

import Foundation
import SwiftUI

class PieChartData: ObservableObject {
    @Published private(set) var data: [SlideData] = []
    let colors = [ Color.red, Color(red: 0.2, green: 0.5, blue: 0.2), Color.orange, Color(red: 1, green: 0.5, blue: 0.5), // 4 count
        Color.blue, Color.purple, Color.pink, Color(red: 0, green: 0.7, blue: 0.7), Color.yellow, Color.green, Color.gray, // 7 count
        Color.black,  Color.white // 2 Extra entries are only to avoid exceptions in future updates (Only 11 are being used)
    ]

    init(name: [String], data: [Double]) {
        var currentAngle: Double = -90
        var slides: [SlideData] = []
        let total = data.reduce(0.0, +)
        
        for index in 0..<data.count {
            let slide = SlideData()
            let dataItem = DataItem(name: name[index], value: data[index], color: colors[index])
            dataItem.highlighted = index == 5
            slide.data = dataItem
            
            let percentage = data[index] / total * 100
            slide.annotation = name[index] + String(format: " %.1f%", percentage)

            slide.startAngle = .degrees(currentAngle)
            let angle = data[index] * 360 / total
            let alpha = currentAngle + angle / 2
            currentAngle += angle
            slide.endAngle = .degrees(currentAngle)
            
            let deltaX = CGFloat(cos(abs(alpha).truncatingRemainder(dividingBy: 90.0) * .pi / 180.0))
            let deltaY = CGFloat(sin(abs(alpha).truncatingRemainder(dividingBy: 90.0) * .pi / 180.0))
            var padding: CGFloat = 0.0
            var paddingX: CGFloat = 0.0
            var paddingY: CGFloat = 0.0
            
            if slide.data.highlighted {
                padding = 0.15
                paddingX = deltaX * 20.0
                paddingY = deltaY * 20.0
            }
            
            let annotationDeltaX = deltaX * (0.7 + padding)
            let annotationDeltaY = deltaY * (0.7 + padding)
            
            if -90 <= alpha && alpha < 0 {
                slide.deltaX = paddingX
                slide.deltaY = -paddingY
                slide.annotationDeltaX = annotationDeltaX
                slide.annotationDeltaY = -annotationDeltaY
            } else if 0 <= alpha && alpha < 90 {
                slide.deltaX = paddingX
                slide.deltaY = paddingY
                slide.annotationDeltaX = annotationDeltaX
                slide.annotationDeltaY = annotationDeltaY
            } else if 90 <= alpha && alpha < 180 {
                slide.deltaX = -paddingY
                slide.deltaY = paddingX
                slide.annotationDeltaX = -annotationDeltaY
                slide.annotationDeltaY = annotationDeltaX
            } else {
                slide.deltaX = -paddingX
                slide.deltaY = -paddingY
                slide.annotationDeltaX = -annotationDeltaX
                slide.annotationDeltaY = -annotationDeltaY
            }
            
            slides.append(slide)
        }
        self.data = slides
    }
    
    init(data: [SlideData]) {
        self.data = data
    }
}
