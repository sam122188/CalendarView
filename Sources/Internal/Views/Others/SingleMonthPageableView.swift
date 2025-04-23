//
//  SingleMonthPageableView.swift
//  MijickCalendarView
//
//  Created by Samantha Nano on 4/18/25.
//

import SwiftUI
import UIKit

struct SingleMonthPageableView : UIViewControllerRepresentable {
    let dataSource: SingleMonthPageableViewDataSource
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical)
        vc.dataSource = dataSource
        if let initialViewController = dataSource.initialViewController() {
            vc.setViewControllers([initialViewController], direction: .forward, animated: false)
        }
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
    }
}

class SingleMonthPageableViewDataSource: NSObject, UIPageViewControllerDataSource {
    let monthData: [Data.MonthView]
    @StateObject var selectedData: Data.MCalendarView
    let configData: CalendarConfig
    let initialIndex: Int
    
    init(monthData: [Data.MonthView], selectedData: StateObject<Data.MCalendarView>, configData: CalendarConfig) {
        self.monthData = monthData
        self._selectedData = selectedData
        self.configData = configData
        
        var initialIndex = monthData.endIndex - 1
        if let selectedDate = selectedData.wrappedValue.date,
           let index = monthData.firstIndex(where: { month in
                month.month.start(of: .month) == selectedDate.start(of: .month)
           }) {
            initialIndex = index
        }
        self.initialIndex = initialIndex
        
        super.init()
    }
    
    func createViewController(for index: Int) -> UIViewController {
        let monthItemView = MonthItem(data: monthData[index], configData: self.configData, selectedData: self.selectedData)
        return SingleMonthViewController(index: index, view: monthItemView)
    }
    
    func initialViewController() -> UIViewController? {
        createViewController(for: self.initialIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let typedController = viewController as? SingleMonthViewController,
              typedController.index > 0
        else { return nil }
        
        return createViewController(for: typedController.index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let typedController = viewController as? SingleMonthViewController,
              typedController.index < self.monthData.endIndex - 1
        else { return nil }
        
        return createViewController(for: typedController.index + 1)
    }
}

class SingleMonthViewController: UIHostingController<MonthItem> {
    let index: Int
    
    init(index: Int, view: MonthItem) {
        self.index = index
        super.init(rootView: view)
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
