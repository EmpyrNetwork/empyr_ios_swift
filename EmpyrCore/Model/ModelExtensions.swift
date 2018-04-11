//
//  ModelExtensions.swift
//  Empyr
//
//  Created by Jarrod Cuzens on 4/10/18.
//

import Foundation

extension RestOffer {
	func getActiveReward() -> String {
		var type = rewardType
		var value = rewardValue
		
		if( details!.hasSchedule && details!.scheduleType == .REWARD ) {
			if let variable = getActiveOffer()
			{
				type = variable.rewardType;
				value = variable.discount;
			}
		}
		
		let format = ( type == .FIXED ? "$%.2f" : "%.0f%%" )
		return String( format: format, value );
	}
	
	func getActiveOffer() -> RestVariableReward? {
		for (_,sched) in details!.schedule {
			for rvr in sched {
				if( rvr.active )
				{
					return rvr;
				}
			}
		}
		
		return nil;
	}
}
