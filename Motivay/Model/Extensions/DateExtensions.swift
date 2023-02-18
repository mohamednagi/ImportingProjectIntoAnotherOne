//
//  DateExtensions.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SwiftDate

extension Date {
    var y_asString: String
    {
        let dateFormatter = DateFormatter()
        if UserSettings.appLanguageIsArabic() {
            
            dateFormatter.locale = NSLocale(localeIdentifier: "ar_AR") as Locale!
        }else{
            
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        }
//        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.dateFormat = "dd MMM yyyy"
        
//        dateFormatter.timeStyle = DateFormatter.Style.none
        return dateFormatter.string(from: self)
    }
    var y_asStringWithTime: String
    {
        let dateFormatter = DateFormatter()
        if UserSettings.appLanguageIsArabic() {
            
            dateFormatter.locale = NSLocale(localeIdentifier: "ar_AR") as Locale!
        }else{
            
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        }
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        dateFormatter.timeStyle = DateFormatter.Style.short
        return dateFormatter.string(from: self)
    }
    var y_ToTimeOnly: String
    {
        let dateFormatter = DateFormatter()
        if UserSettings.appLanguageIsArabic() {
            
            dateFormatter.locale = NSLocale(localeIdentifier: "ar_AR") as Locale!
        }else{
            
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        }
        
        dateFormatter.dateStyle = DateFormatter.Style.none
        
        dateFormatter.timeStyle = DateFormatter.Style.short
        return dateFormatter.string(from: self)
    }
    
    func y_addDaysToCurrentDate(numofDays: Int) -> Date
    {
        let today = self
        return Calendar.current.date(byAdding: .day, value: numofDays, to: today)!
    }
    var y_trimTime: Date {
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        return (cal as NSCalendar).date(bySettingHour: 2, minute: 0, second: 0, of: self, options: NSCalendar.Options())!
    }
    
    func y_timeAgoSinceDate(numericDates:Bool) -> String {
        
        let date = self as NSDate
        
        let calendar = NSCalendar.current
//        calendar.timeZone = TimeZone.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
//        DeveloperTools.print("now == ", now)
//        DeveloperTools.print("then == ", date)
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        var components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)

        if (components.year! >= 2) {
            return "\(components.year!) years"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour"
            } else {
                return "An hour"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute"
            } else {
                return "A minute"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds"
        } else {
            return "Just now"
        }
        
    }
    
    func y_timeAgoTodayOnlySinceDate(numericDates:Bool) -> String {
        
        let date = self as NSDate
        
        let calendar = NSCalendar.current
        //        calendar.timeZone = TimeZone.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        //        DeveloperTools.print("now == ", now)
        //        DeveloperTools.print("then == ", date)
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        var components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        dateFormatter.timeZone =  TimeZone(abbreviation: "UTC")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        
        if (components.year! >= 1 ||
            components.month! >= 1 ||
            components.weekOfYear! >= 1 ||
            components.day! >= 1){
            return dateFormatter.string(from: self)
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour"
            } else {
                return "An hour"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute"
            } else {
                return "A minute"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds"
        } else {
            return "Just now"
        }
        
    }
    
    func y_timeAgoSinceDateInArabic() -> String {
        let date = self as NSDate
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 11) {
            return "\(components.year!) سنة"
        } else if (components.year! >= 3){
            return "\(components.year!) سنوات"
        } else if (components.year! == 2){
            return "سنتان"
        } else if (components.year! == 1){
            return "سنة واحدة"
        } else if (components.month! >= 11) {
            return "\(components.month!) شهر"
        } else if (components.month! >= 3){
            return "\(components.month!) شهور"
        } else if (components.month! == 2){
            return "شهران"
        } else if (components.month! == 1){
            return "شهر واحد"
        } else if (components.weekOfYear! >= 11) {
            return "\(components.weekOfYear!) أسبوع"
        }  else if (components.weekOfYear! >= 3){
            return "\(components.weekOfYear!) أسابيع"
        } else if (components.weekOfYear! == 2){
            return "إسبوعان"
        } else if (components.weekOfYear! == 1){
            return "إسبوع واحد"
        } else if (components.day! >= 11) {
            return "\(components.day!) يوم"
        }  else if (components.day! >= 3){
            return "\(components.day!) أيام"
        } else if (components.day! == 2){
            return "يومان"
        } else if (components.day! == 1){
            return "يوم واحد"
        } else if (components.hour! >= 11) {
            return "\(components.hour!) ساعة"
        }  else if (components.hour! >= 3){
            return "\(components.hour!) ساعات"
        } else if (components.hour! == 2){
            return "ساعتان"
        } else if (components.hour! == 1){
            return "ساعة واحدة"
        } else if (components.minute! >= 11) {
            return "\(components.minute!) دقيقة"
        }  else if (components.minute! >= 3){
            return "\(components.minute!) دقائق"
        } else if (components.minute! == 2){
            return "دقيقتان"
        } else if (components.minute! == 1){
            return "دقيقة واحدة"
        } else if (components.second! >= 11) {
            return "\(components.second!) ثانية"
        }  else if (components.second! >= 3){
            return "\(components.second!) ثواني"
        } else if (components.second! == 2){
            return "ثانيتان"
        } else if (components.second! == 1){
            return "ثانية واحدة"
        } else {
            return "الآن"
        }
        
    }
    
    func y_timeAgoTodayOnlySinceDateInArabic() -> String {
        let date = self as NSDate
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        dateFormatter.timeZone =  TimeZone(abbreviation: "UTC")
//        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        
        if (components.year! >= 1 ||
            components.month! >= 1 ||
            components.weekOfYear! >= 1 ||
            components.day! >= 1){
            return dateFormatter.string(from: self)
        } else if (components.hour! >= 11) {
            return "\(components.hour!) ساعة"
        }  else if (components.hour! >= 3){
            return "\(components.hour!) ساعات"
        } else if (components.hour! == 2){
            return "ساعتان"
        } else if (components.hour! == 1){
            return "ساعة واحدة"
        } else if (components.minute! >= 11) {
            return "\(components.minute!) دقيقة"
        }  else if (components.minute! >= 3){
            return "\(components.minute!) دقائق"
        } else if (components.minute! == 2){
            return "دقيقتان"
        } else if (components.minute! == 1){
            return "دقيقة واحدة"
        } else if (components.second! >= 11) {
            return "\(components.second!) ثانية"
        }  else if (components.second! >= 3){
            return "\(components.second!) ثواني"
        } else if (components.second! == 2){
            return "ثانيتان"
        } else if (components.second! == 1){
            return "ثانية واحدة"
        } else {
            return "الآن"
        }
        
    }
    
}
