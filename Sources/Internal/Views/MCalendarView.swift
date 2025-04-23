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
    var useSingleMonthView = false
    let pageableViewDataSource: SingleMonthPageableViewDataSource


    init(_ selectedDate: Binding<Date?>?, _ selectedRange: Binding<MDateRange?>?, _ configBuilder: (CalendarConfig) -> CalendarConfig) {
        self._selectedData = .init(wrappedValue: .init(selectedDate, selectedRange))
        self.configData = configBuilder(.init())
        self.monthsData = .generate()
        self.pageableViewDataSource = SingleMonthPageableViewDataSource(monthData: self.monthsData, selectedData: _selectedData, configData: configData)
    }
    public var body: some View {
        VStack(spacing: 12) {
            createWeekdaysView()
            if (self.useSingleMonthView) {
                SingleMonthPageableView(dataSource: pageableViewDataSource)
            } else {
                createScrollView()
            }
        }
    }
}
private extension MCalendarView {
    func createWeekdaysView() -> some View {
        configData.weekdaysView().erased()
    }
    func createScrollView() -> some View { ScrollViewReader { reader in
        return ScrollView(showsIndicators: false) {
            LazyVStack(spacing: configData.monthsSpacing) {
                ForEach(monthsData, id: \.month, content: createMonthItem)
            }
            .padding(.top, configData.monthsPadding.top)
            .padding(.bottom, configData.monthsPadding.bottom)
            .background(configData.monthsViewBackground)
        }
        .onAppear() { scrollToDate(reader, animatable: false) }
        .onChange(of: configData.scrollDate) { _ in scrollToDate(reader, animatable: true) }
    }}
}
private extension MCalendarView {
    func createMonthItem(_ data: Data.MonthView) -> some View {
        MonthItem(data: data, configData: self.configData, selectedData: self.selectedData)
    }
}

// MARK: - Modifiers
private extension MCalendarView {
    func scrollToDate(_ reader: ScrollViewProxy, animatable: Bool) {
        guard let date = configData.scrollDate else { return }

        let scrollDate = date.start(of: .month)
        withAnimation(animatable ? .default : nil) { reader.scrollTo(scrollDate, anchor: .center) }
    }
}
