//
//  Calendar+extension.swift
//  VGSCollectSDK
//
//  Created by Dima on 22.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal extension Calendar {
  
  /// For card numbers we should use `gregorian` calendar. Note: Callendar.current could retern different calendars!!!
  static var currentMonth: Int {
    return Calendar(identifier: .gregorian).component(.month, from: Date())
  }
  
   static var currentYear: Int {
    return Calendar(identifier: .gregorian).component(.year, from: Date())
  }
  
  static var currentYearShort: Int {
    return Calendar(identifier: .gregorian).component(.year, from: Date()) - 2000
  }
}

/// :nodoc:
public final class VGSCalendarUtils {

	public static var currentYear: Int {
	 return Calendar(identifier: .gregorian).component(.year, from: Date())
	}

	public static var currentYearShort: Int {
		return Calendar(identifier: .gregorian).component(.year, from: Date()) - 2000
	}
}
