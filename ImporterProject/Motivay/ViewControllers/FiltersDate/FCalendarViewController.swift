//
//  FCalendarViewController.swift
//  
//
//  Created by Yasser Osama on 1/10/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit
import FSCalendar

protocol DateRangeSelectedDelegate: class {
    func userSelectedDateRange(start: Date?, end: Date?)
}

class FilterCalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    //MARK: Outlets
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var applyButton: UIButton!//ButtonFontLAng!
    
    var rightButton : UIBarButtonItem!
    var initialStartDate: Date?
    var initialEndDate: Date?
    
    var nowDeselect = false
    
    //MARK: Properties
    weak var delegate: DateRangeSelectedDelegate? = nil
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.appearance.selectionColor = .primaryColor
        calendarView.appearance.todaySelectionColor = .primaryColor
        calendarView.appearance.todayColor = UIColor.primaryColorWithAlpha
        calendarView.allowsMultipleSelection = true
        if UserSettings.appLanguageIsArabic() {
            calendarView.locale = Locale(identifier: "ar")
            calendarView.appearance.caseOptions = .weekdayUsesUpperCase
            
//            calendar.identifier = NSCalendar.Identifier.ara
            calendarView.firstWeekday = 7
            
//            calendarView.calendarHeaderView.calendar.locale = Locale(identifier: "ar")
//            calendarView.firstWeekday = 1
            
//            calendarView.semanticContentAttribute = .forceRightToLeft
        }else{
        
            calendarView.locale = Locale(identifier: "en")
            calendarView.appearance.caseOptions = .weekdayUsesUpperCase
            calendarView.firstWeekday = 1
        }
        
//        clearButton.roundCorners()
//        applyButton.roundCorners()
        rightButton = UIBarButtonItem(title: /*"Done"*/"Select".y_localized, style: .plain, target: self, action: #selector(applyAction(_:)))
        rightButton.isEnabled = false
        
        self.navigationItem.rightBarButtonItem = rightButton
        self.title = "Date range".y_localized
        if initialStartDate != nil {
            while initialStartDate! <= initialEndDate! {
                
                calendarView.select(initialStartDate)
                initialStartDate = calendarView.gregorian.date(byAdding: .day, value: 1, to: initialStartDate!)!
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.navigationController?.y_whiteBackground()
        self.navigationController?.y_showShadow()
    }
    //MARK: FSCalendar DataSource Methods
    func minimumDate(for calendar: FSCalendar) -> Date {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy"
//        let date = formatter.date(from: "01/01/2017")!
        var dateComp = DateComponents()
        dateComp.year = -1
        let date = Calendar.current.date(byAdding: dateComp, to: Date())!
        return date
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    //MARK: FSCalendar Delegate Methods
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        rightButton.isEnabled = true
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        
        let datesWithoutLastSelected = calendar.selectedDates.filter{ $0 != date}
        
//        DeveloperTools.print("did select")
//        DeveloperTools.print(calendar.selectedDates)
//        DeveloperTools.print(date)
//        print(fmt.string(from: date))
//        print(calendar.selectedDates.sorted())
        
        if calendar.selectedDates.count > 1 {
            
            var startDate = calendar.selectedDates.sorted().first!
            var endDate = calendar.selectedDates.sorted().last!
            
            let datesWithoutLastSelectedStartDate = datesWithoutLastSelected.sorted().first!
            let datesWithoutLastSelectedEndDate = datesWithoutLastSelected.sorted().last!
            
            if datesWithoutLastSelected.count > 1 &&
                (date < datesWithoutLastSelectedStartDate || date > datesWithoutLastSelectedEndDate) {
                //outside the range reset
                startDate = date
                endDate = date
            } else if calendar.selectedDates.contains(date) {
                endDate = date
            }
            
            for selD in calendar.selectedDates {
                calendar.deselect(selD)
            }
            
            print("select")
            while startDate <= endDate {
//                print(fmt.string(from: startDate))
                calendar.select(startDate)
                startDate = calendar.gregorian.date(byAdding: .day, value: 1, to: startDate)!
//                DeveloperTools.print("select: ", startDate)
                
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        rightButton.isEnabled = true
//        DeveloperTools.print("did deselect")
        if calendar.selectedDates.contains(date) {
            calendar.select(date)
        }
        if calendar.selectedDates.count == 0 {
            calendar.select(date)
        }
        
        var startDate = calendar.selectedDates.sorted().first!
        var endDate = calendar.selectedDates.sorted().last!
        
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        
        for selD in calendar.selectedDates {
            calendar.deselect(selD)
        }
        while startDate <= endDate {
//            print(fmt.string(from: startDate))
            if date == startDate {
                endDate = date
            }
            if nowDeselect {
                calendar.select(startDate)
                nowDeselect = true
            }
//            startDate = calendar.date(byAddingDays: 1, to: startDate)
            
            startDate = calendar.gregorian.date(byAdding: .day, value: 1, to: startDate)!
        }
    }
    
    @IBAction func backAction(_ sender: UIButton/*myBarButtonBackImg*/) {
        self.navigationController?.popViewController(animated: true)
    }
    
//    @IBAction func todayAction(_ sender: UIBarButtonItem) {
//        if calendarView.selectedDates.contains(calendarView.today!) {
//            calendarView.select(calendarView.today, scrollToDate: true)
//        } else {
//            calendarView.select(calendarView.today, scrollToDate: true)
//            calendarView.deselect(calendarView.today!)
//        }
//    }
//
//    @IBAction func clearAction(_ sender: UIButton/*ButtonFontLAng*/) {
//        for selected in calendarView.selectedDates {
//            calendarView.deselect(selected)
//        }
//    }
    
    @IBAction func applyAction(_ sender: UIButton/*ButtonFontLAng*/) {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        
        if calendarView.selectedDates.count > 0 {
            let startDate = calendarView.selectedDates.sorted().first!
            let endDate = calendarView.selectedDates.sorted().last!
            delegate?.userSelectedDateRange(start: /*fmt.string(from: */startDate/*)*/, end: /*fmt.string(from: */endDate/*)*/)
            self.navigationController?.popViewController(animated: true)
        } else {
            delegate?.userSelectedDateRange(start: nil, end:nil)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}
