////
///  FreeMethods.swift
//

import UIKit


#if DEBUG
var messages: [(String, String)] = []
func log(comment: String, object: Any?) {
    if let object = object {
        messages.append((comment, "\(object)"))
    }
    else {
        messages.append((comment, "nil"))
    }
}
func getlog() -> [(String, String)] {
    let m = messages
    messages.removeAll()
    return m
}
#else
func log(comment: String, object: Any?) {}
func getlog() -> [(String, String)] { return [] }
#endif


// MARK: Animations

public struct AnimationOptions {
    let duration: NSTimeInterval
    let delay: NSTimeInterval
    let options: UIViewAnimationOptions
    let completion: ((Bool) -> Void)?
}

public let DefaultAnimationDuration: NSTimeInterval = 0.2
public let DefaultAppleAnimationDuration: NSTimeInterval = 0.3
public func animate(duration duration: NSTimeInterval = DefaultAnimationDuration, delay: NSTimeInterval = 0, options: UIViewAnimationOptions = .TransitionNone, animated: Bool? = nil, completion: ((Bool) -> Void)? = nil, animations: () -> Void) {
    let shouldAnimate: Bool = animated ?? !AppSetup.sharedState.isTesting
    let options = AnimationOptions(duration: duration, delay: delay, options: options, completion: completion)
    animate(options, animated: shouldAnimate, animations: animations)
}

public func animate(options: AnimationOptions, animated: Bool = true, animations: () -> Void) {
    if animated {
        UIView.animateWithDuration(options.duration, delay: options.delay, options: options.options, animations: animations, completion: options.completion)
    }
    else {
        animations()
        options.completion?(true)
    }
}


// MARK: Async, Timed, and Throttled closures

public typealias BasicBlock = (() -> Void)
public typealias ThrottledBlock = ((BasicBlock) -> Void)
public typealias CancellableBlock = Bool -> Void
public typealias TakesIndexBlock = ((Int) -> Void)


public class Proc {
    var block: BasicBlock

    public init(_ block: BasicBlock) {
        self.block = block
    }

    @objc
    func run() {
        block()
    }
}


public func times(times: Int, @noescape block: BasicBlock) {
    times_(times) { (index: Int) in block() }
}

public func profiler(message: String = "") -> BasicBlock {
    let start = NSDate()
    print("--------- PROFILING \(message)...")
    return {
        print("--------- PROFILING \(message): \(NSDate().timeIntervalSinceDate(start))")
    }
}

public func profiler(message: String = "", @noescape block: BasicBlock) {
    let p = profiler(message)
    block()
    p()
}

public func times(times: Int, @noescape block: TakesIndexBlock) {
    times_(times, block: block)
}

private func times_(times: Int, @noescape block: TakesIndexBlock) {
    if times <= 0 {
        return
    }
    for i in 0 ..< times {
        block(i)
    }
}

public func after(times: Int, block: BasicBlock) -> BasicBlock {
    if times == 0 {
        block()
        return {}
    }

    var remaining = times
    return {
        remaining -= 1
        if remaining == 0 {
            block()
        }
    }
}

public func until(times: Int, block: BasicBlock) -> BasicBlock {
    if times == 0 {
        return {}
    }

    var remaining = times
    return {
        remaining -= 1
        if remaining >= 0 {
            block()
        }
    }
}

public func once(block: BasicBlock) -> BasicBlock {
    return until(1, block: block)
}

public func inBackground(block: BasicBlock) {
    if AppSetup.sharedState.isTesting {
        block()
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
    }
}

public func inForeground(block: BasicBlock) {
    nextTick(block)
}

public func nextTick(block: BasicBlock) {
    if AppSetup.sharedState.isTesting {
        if NSThread.isMainThread() {
            block()
        }
        else {
            dispatch_sync(dispatch_get_main_queue(), block)
        }
    }
    else {
        nextTick(on: dispatch_get_main_queue(), block: block)
    }
}

public func nextTick(on on: dispatch_queue_t, block: BasicBlock) {
    dispatch_async(on, block)
}

public func timeout(duration: NSTimeInterval, block: BasicBlock) -> BasicBlock {
    let handler = once(block)
    _ = delay(duration) {
        handler()
    }
    return handler
}

public func delay(duration: NSTimeInterval, background: Bool = false, block: BasicBlock) {
    let killTimeOffset = Int64(CDouble(duration) * CDouble(NSEC_PER_SEC))
    let killTime = dispatch_time(DISPATCH_TIME_NOW, killTimeOffset)
    let queue = background ? dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) : dispatch_get_main_queue()
    dispatch_after(killTime, queue, block)
}

public func cancelableDelay(duration: NSTimeInterval, block: BasicBlock) -> BasicBlock {
    let killTimeOffset = Int64(CDouble(duration) * CDouble(NSEC_PER_SEC))
    let killTime = dispatch_time(DISPATCH_TIME_NOW, killTimeOffset)
    var cancelled = false
    dispatch_after(killTime, dispatch_get_main_queue()) {
        if !cancelled { block() }
    }
    return { cancelled = true }
}

public func debounce(timeout: NSTimeInterval, block: BasicBlock) -> BasicBlock {
    var timer: NSTimer? = nil
    let proc = Proc(block)

    return {
        if let prevTimer = timer {
            prevTimer.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: proc, selector: #selector(Proc.run), userInfo: nil, repeats: false)
    }
}

public func debounce(timeout: NSTimeInterval) -> ThrottledBlock {
    var timer: NSTimer? = nil

    return { block in
        if let prevTimer = timer {
            prevTimer.invalidate()
        }
        let proc = Proc(block)
        timer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: proc, selector: #selector(Proc.run), userInfo: nil, repeats: false)
    }
}

public func throttle(interval: NSTimeInterval, block: BasicBlock) -> BasicBlock {
    var timer: NSTimer? = nil
    let proc = Proc() {
        timer = nil
        block()
    }

    return {
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: proc, selector: #selector(Proc.run), userInfo: nil, repeats: false)
        }
    }
}

public func throttle(interval: NSTimeInterval) -> ThrottledBlock {
    var timer: NSTimer? = nil
    var lastBlock: BasicBlock?

    return { block in
        lastBlock = block

        if timer == nil {
            let proc = Proc() {
                timer = nil
                lastBlock?()
            }

            timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: proc, selector: #selector(Proc.run), userInfo: nil, repeats: false)
        }
    }
}
