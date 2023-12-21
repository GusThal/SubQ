//
//  InjectionView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 12/17/23.
//

import SwiftUI
import WidgetKit

struct DescriptionView: View {
    
    let injection: Injection
    
    var body: some View {
        HStack(spacing: 2){
            Text(injection.name!)
                .bold()
            Text("\(injection.dosage!) \(injection.units!)")
        }.font(.caption2)
        
        
    }
}

struct InjectionView: View {
    
    let injection: Injection
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    var body: some View {
        if widgetFamily == .systemSmall {
            VStack(alignment: .leading) {
               DescriptionView(injection: injection)
                
                Text(injection.nextInjection!.date.shortenedDateTime)
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
        } else {
            HStack {
                DescriptionView(injection: injection)
                
                Spacer()
                
                Text(injection.nextInjection!.date.shortenedDateTime)
                    .font(.caption2)
                    .foregroundStyle(.gray)
                
                
            }
        }
    }

}
/*
#Preview {
    InjectionView()
}
*/
