////
///  Math.swift
//
//  Created by Andy Matuschak on 10/16/14.
//  Copyright (c) 2014 Khan Academy. All rights reserved.
//
//  From https://github.com/Khan/Prototope/blob/master/Prototope/Math.swift

/** Linearly interpolates between the from: value and the to: value based on the at:
fraction. When at:0, returns the from: value. When at: 1, returns the to: value.

For example:
interpolate(from: 5, to: 15, at: 0.5) // Returns 10

Like Processing's lerp() */
func interpolate(from fromValue: Double, to toValue: Double, at fraction: Double) -> Double {
    return fraction * (toValue - fromValue) + fromValue
}

/** Maps a value from one interval to another.

For example:
map(value: 0.4, fromInterval: (0, 1), toInterval: (0, 10)) // Returns 4

Like Processing's map(). */
func map(_ value: Double, fromInterval: (Double, Double), toInterval: (Double, Double)) -> Double {
    return interpolate(from: toInterval.0, to: toInterval.1, at: (value - fromInterval.0) / (fromInterval.1 - fromInterval.0))
}
func map(_ value: CGFloat, fromInterval: (CGFloat, CGFloat), toInterval: (CGFloat, CGFloat)) -> CGFloat {
    return CGFloat(map(Double(value), fromInterval: (Double(fromInterval.0), Double(fromInterval.1)), toInterval: (Double(toInterval.0), Double(toInterval.1))))
}
/** Clips a value so that it falls between the specified minimum and maximum. */
func clip<T: Comparable>(_ value: T, min minValue: T, max maxValue: T) -> T {
    return max(min(value, maxValue), minValue)
}

/** `ceil`s the value, snapping to screen's pixel values */
func pixelAwareCeil(_ value: Double) -> Double {
    let scale = Double(UIScreen.main.scale)
    return ceil(value*scale)/scale
}

/** `floor`s the value, snapping to screen's pixel values */
func pixelAwareFloor(_ value: Double) -> Double {
    let scale = Double(UIScreen.main.scale)
    return floor(value*scale)/scale
}

func calculateColumnWidth(frameWidth: CGFloat, columnCount: Int) -> CGFloat {
    return floor((frameWidth - StreamCollectionViewLayout.Size.defaultColumnSpacing * CGFloat(columnCount - 1)) / CGFloat(columnCount))
}
