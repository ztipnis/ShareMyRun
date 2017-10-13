//
//  LocCtrl.swift
//  ShareMyRun
//
//  Created by Zachary Tipnis on 1/11/16.
//  Copyright © 2016 Zachal. All rights reserved.
//

import Foundation

var dSin: (inDeg: Double) -> Double = {
    
    let ans =  sin(((fmod($0, 360) > 270 ? fmod($0, 360) - 270 : ((fmod($0, 360) > 90) ? 180 - fmod($0, 360) : fmod($0, 360))) * M_PI / 180.00))
    return ans

}

var dCos: (inDeg: Double) -> Double = {
    
    let ans =  cos(((fmod($0, 360) > 270 ? fmod($0, 360) - 270 : ((fmod($0, 360) > 90) ? 180 - fmod($0, 360) : fmod($0, 360))) * M_PI / 180.00))
    return ans
    
}

var dAtan2: (inAngX: Double, inAngY: Double) -> Double = {

    let ans = atan2($0, $1)
    return ans
}

var LatLongToMeter: (Lat1: Double, Lat2: Double, Long1:Double, Long2:Double) -> Double = {

    let R = 6371000
    let radPhi1 = $0 * (M_PI / 180.00)
    let radPhi2 = $1 * (M_PI / 180.00)
    let radLambda1 = $2 * (M_PI / 180.00)
    let radLambda2 = $3 * (M_PI / 180.00)
    let dPhi = $1 - $0
    let dLambda = $3 - $2
    let a = dSin(inDeg: dPhi/2) * dSin(inDeg: dPhi/2) +
        dCos(inDeg: $0) * dCos(inDeg: $1) *
        dSin(inDeg: dLambda/2) * dSin(inDeg: dLambda/2)
    let c = 2 * dAtan2(inAngX: sqrt(a), inAngY: sqrt(1-a))
    let d = 6371000 * c
    return d
}