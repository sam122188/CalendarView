//
//  SwiftUIView.swift
//  MijickCalendarView
//
//  Created by Samantha Nano on 4/22/25.
//

import SwiftUI

struct MonthItem: View {
    let data: Data.MonthView
    let configData: CalendarConfig
    @ObservedObject var selectedData: Data.MCalendarView
    
    func createMonthLabel() -> some View {
        configData.monthLabel(data.month)
            .erased()
            .onAppear { onMonthChange(data.month) }
    }
    func createMonthView() -> some View {
        MonthView(selectedDate: $selectedData.date, selectedRange: $selectedData.range, data: data, config: configData)
    }
    
    func onMonthChange(_ date: Date) { configData.onMonthChange(date) }
    
    var body: some View {
        VStack(spacing: configData.monthLabelDaysSpacing) {
            createMonthLabel()
            createMonthView()
        }
    }
}
