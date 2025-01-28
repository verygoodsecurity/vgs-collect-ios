//
//  VGSFormAnanlyticsDetails.swift
//  VGSCollectSDK
//
//  Created by Dima on 26.11.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// :nodoc:  VGSCollect Form Analytics Details
public struct VGSFormAnanlyticsDetails {
  public let formId: String
  public let tenantId: String
  public let environment: String

	public init(formId: String, tenantId: String, environment: String) {
		self.formId = formId
		self.tenantId = tenantId
		self.environment = environment
	}
}
