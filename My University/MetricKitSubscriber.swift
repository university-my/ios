//
//  MetricKitSubscriber.swift
//  My University
//
//  Created by Yura Voevodin on 27.06.2020.
//  Copyright © 2020 Yura Voevodin. All rights reserved.
//

import MetricKit

class MetricKitSubscriber: NSObject, MXMetricManagerSubscriber {
    
    var metricManager: MXMetricManager?
    
    override init() {
        super.init()
        metricManager = MXMetricManager.shared
        metricManager?.add(self)
    }
    
    deinit {
        metricManager?.remove(self)
    }
    
    func didReceive(_ payload: [MXMetricPayload]) {
        //        for metricPayload in payload {
        //         Do something with metricPayload.
        //        }
    }
    
    func didReceive(_ payload: [MXDiagnosticPayload]) {
        //        for diagnosticPayload in payload {
        //        Consume diagnosticPayload.
        //        }
    }
}
