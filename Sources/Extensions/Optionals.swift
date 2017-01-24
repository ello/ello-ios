//
//  Optionals.swift
//  Ello
//
//  From tomlokhorst
//  https://gist.github.com/tomlokhorst/f9a826bf24d16cb5f6a3
//  Created by Sean Dougherty on 12/15/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

func unwrap<T1, T2>(_ optional1: T1?, optional2: T2?) -> (T1, T2)? {
    switch (optional1, optional2) {
    case let (.some(value1), .some(value2)):
        return (value1, value2)
    default:
        return nil
    }
}

func unwrap<T1, T2, T3>(_ optional1: T1?, optional2: T2?, optional3: T3?) -> (T1, T2, T3)? {
    switch (optional1, optional2, optional3) {
    case let (.some(value1), .some(value2), .some(value3)):
        return (value1, value2, value3)
    default:
        return nil
    }
}

func unwrap<T1, T2, T3, T4>(_ optional1: T1?, optional2: T2?, optional3: T3?, optional4: T4?) -> (T1, T2, T3, T4)? {
    switch (optional1, optional2, optional3, optional4) {
    case let (.some(value1), .some(value2), .some(value3), .some(value4)):
        return (value1, value2, value3, value4)
    default:
        return nil
    }
}

func unwrap<T1, T2, T3, T4, T5>(_ optional1: T1?, optional2: T2?, optional3: T3?, optional4: T4?, optional5: T5?) -> (T1, T2, T3, T4, T5)? {
    switch (optional1, optional2, optional3, optional4, optional5) {
    case let (.some(value1), .some(value2), .some(value3), .some(value4), .some(value5)):
        return (value1, value2, value3, value4, value5)
    default:
        return nil
    }
}
