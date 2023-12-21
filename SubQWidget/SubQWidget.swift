//
//  SubQWidget.swift
//  SubQWidget
//
//  Created by Constantine Thalasinos on 12/14/23.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    
    private var managedObjectContext = StorageProvider.shared.persistentContainer.viewContext
    
    func getInjections() -> [Injection] {
        let request = Injection.scheduledInjections
        
        return try! managedObjectContext.fetch(request)
    }
    
    func getInjectionsSortedByNextDate() -> [Injection] {
        
        return getInjections().sorted { inj1, inj2 in
            return inj1.nextInjection!.date < inj2.nextInjection!.date
        }
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), injections: [Injection]())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        let injections = getInjectionsSortedByNextDate()
        
        let entry = SimpleEntry(date: Date(), injections: injections)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        print("timeline called")
        
        let injections = getInjectionsSortedByNextDate()
        
        
        let nextInjectionDate = injections[0].nextInjection!.date
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        
        let first = SimpleEntry(date: Date(), injections: injections)
        
        let last = SimpleEntry(date: nextInjectionDate, injections: injections)
        var entries: [SimpleEntry] = [first, last]
        

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let injections: [Injection]
    
    func getLimitedInjections(forWidgetFamily family: WidgetFamily) -> [Injection]{
        if family == .systemSmall {
            if injections.count > 3 {
               return Array(injections.prefix(through: 2))
            }
        } else if family == .systemMedium {
            if injections.count > 4 {
                return Array(injections.prefix(through: 3))
            }
        } else if family == .systemLarge {
            if injections.count > 12 {
                return Array(injections.prefix(through: 11))
            }
        }
        
        return injections
    }
}


struct SubQWidgetEntryView : View {
    var entry: Provider.Entry
    
/*    @FetchRequest(fetchRequest: Injection.scheduledInjections)
    private var injections: FetchedResults<Injection>*/
    @Environment(\.widgetFamily) private var widgetFamily
    
 /*   private var sortedInjections: [Injection] {
        return injections.sorted { inj1, inj2 in
            return inj1.nextInjection!.date < inj2.nextInjection!.date
        }
    }*/

    var body: some View {
       
        
        VStack {
            HStack {
                if widgetFamily == .systemSmall {
                    Text("Scheduled")
                        .font(.caption2)
                        .fontWeight(.bold)
                } else {
                    Text("Scheduled Injections")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                
                Spacer()
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34.25, height: 11.25)
            }
            Divider()
            
            ForEach(entry.getLimitedInjections(forWidgetFamily: widgetFamily)) { injection in
                
                InjectionView(injection: injection)
                    
                Divider()
                
            }
            
            Spacer()
            
        }
    }
}

struct SubQWidget: Widget {
    let kind: String = "SubQWidget"
    
    let storageProvider = StorageProvider.shared

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
           
            SubQWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .environment(\.managedObjectContext, storageProvider.persistentContainer.viewContext)
            
        }
        .configurationDisplayName("Upcoming Injections")
        .description("See your scheduled injections at a glance.")
        .supportedFamilies([.systemSmall, .systemLarge, .systemMedium])
    }
}
/*
#Preview(as: .systemSmall) {
    SubQWidget()
} timeline: {
    SimpleEntry(date: .now)
    SimpleEntry(date: .now)
}*/
