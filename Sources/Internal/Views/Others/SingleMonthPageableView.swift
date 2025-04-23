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
    
    init(monthData: [Data.MonthView], selectedData: StateObject<Data.MCalendarView>, configData: CalendarConfig) {
        self.monthData = monthData
        self._selectedData = selectedData
        self.configData = configData
    }
    
    func initialViewController() -> UIViewController? {
        guard let selectedDate = selectedData.date,
              let initialIndex = monthData.firstIndex(where: { month in
                  month.month.start(of: .month) == selectedDate.start(of: .month)
              })
        else { return nil }
        
        let monthItemView = MonthItem(data: monthData[initialIndex], configData: self.configData, selectedData: self.selectedData)
        return UIHostingController(rootView: monthItemView)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
}

class SingleMonthViewController: UIHostingController<MonthView> {
    let month: Date
    
    init(month: Date, view: MonthView) {
        self.month = month
        super.init(rootView: view)
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
