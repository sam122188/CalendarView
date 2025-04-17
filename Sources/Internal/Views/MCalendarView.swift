//
//  MCalendarView.swift of CalendarView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

public struct MCalendarView: View {
    @StateObject var selectedData: Data.MCalendarView
    let monthsData: [Data.MonthView]
    let configData: CalendarConfig
    @State var useSingleMonthView = false


    init(_ selectedDate: Binding<Date?>?, _ selectedRange: Binding<MDateRange?>?, _ configBuilder: (CalendarConfig) -> CalendarConfig) {
        self._selectedData = .init(wrappedValue: .init(selectedDate, selectedRange))
        self.configData = configBuilder(.init())
        self.monthsData = .generate()
    }
    public var body: some View {
        VStack(spacing: 12) {
            createWeekdaysView()
            createScrollView()
        }
    }
}
private extension MCalendarView {
    func createWeekdaysView() -> some View {
        configData.weekdaysView().erased()
    }
    func createScrollView() -> some View { ScrollViewReader { reader in
        var limitBehavior = ViewAlignedScrollTargetBehavior.LimitBehavior.never
        if (self.useSingleMonthView) {
            limitBehavior = .automatic
            if #available(iOS 18, *) {
                limitBehavior = .alwaysByOne
            }
        }
        
        return ScrollView(showsIndicators: false) {
            LazyVStack(spacing: configData.monthsSpacing) {
                ForEach(monthsData, id: \.month, content: createMonthItem)
            }
            .padding(.top, configData.monthsPadding.top)
            .padding(.bottom, configData.monthsPadding.bottom)
            .background(configData.monthsViewBackground)
            .scrollTargetLayout()
        }
        .onAppear() { scrollToDate(reader, animatable: false) }
        .onChange(of: configData.scrollDate) { _ in scrollToDate(reader, animatable: true) }
        .scrollTargetBehavior(.viewAligned(limitBehavior: limitBehavior))
    }}
}
private extension MCalendarView {
    func createMonthItem(_ data: Data.MonthView) -> some View {
        VStack(spacing: configData.monthLabelDaysSpacing) {
            createMonthLabel(data.month)
            createMonthView(data)
        }
    }
}
private extension MCalendarView {
    func createMonthLabel(_ month: Date) -> some View {
        configData.monthLabel(month)
            .erased()
            .onAppear { onMonthChange(month) }
    }
    func createMonthView(_ data: Data.MonthView) -> some View {
        MonthView(selectedDate: $selectedData.date, selectedRange: $selectedData.range, data: data, config: configData)
    }
}

// MARK: - Modifiers
private extension MCalendarView {
    func scrollToDate(_ reader: ScrollViewProxy, animatable: Bool) {
        guard let date = configData.scrollDate else { return }

        let scrollDate = date.start(of: .month)
        withAnimation(animatable ? .default : nil) { reader.scrollTo(scrollDate, anchor: .center) }
    }
    func onMonthChange(_ date: Date) { configData.onMonthChange(date) }
}
