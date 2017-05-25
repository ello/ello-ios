////
///  FreeMethods.swift
//

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

struct AnimationOptions {
    let duration: TimeInterval
    let delay: TimeInterval
    let options: UIViewAnimationOptions
    let completion: ((Bool) -> Void)
}

let DefaultAnimationDuration: TimeInterval = 0.2
let DefaultAppleAnimationDuration: TimeInterval = 0.3
func animate(duration: TimeInterval = DefaultAnimationDuration, delay: TimeInterval = 0, options: UIViewAnimationOptions = UIViewAnimationOptions(), animated: Bool? = nil, completion: @escaping ((Bool) -> Void) = { _ in }, animations: @escaping () -> Void) {
    let shouldAnimate: Bool = animated ?? !AppSetup.sharedState.isTesting
    let options = AnimationOptions(duration: duration, delay: delay, options: options, completion: completion)
    animate(options: options, animated: shouldAnimate, animations: animations)
}

func animateWithKeyboard(animated: Bool? = nil, completion: @escaping ((Bool) -> Void) = { _ in }, animations: @escaping () -> Void) {
    animate(duration: Keyboard.shared.duration, options: Keyboard.shared.options, animated: animated, completion: completion, animations: animations)
}

func animate(options: AnimationOptions, animated: Bool = true, animations: @escaping () -> Void) {
    if animated {
        UIView.animate(withDuration: options.duration, delay: options.delay, options: options.options, animations: animations, completion: options.completion)
    }
    else {
        animations()
        options.completion(true)
    }
}


// MARK: Async, Timed, and Throttled closures

typealias BasicBlock = () -> Void
typealias AfterBlock = () -> BasicBlock
typealias ThrottledBlock = (@escaping BasicBlock) -> Void
typealias TakesIndexBlock = (Int) -> Void
typealias OnHeightMismatch = (CGFloat) -> Void


class Proc {
    var block: BasicBlock

    init(_ block: @escaping BasicBlock) {
        self.block = block
    }

    @objc
    func run() {
        block()
    }
}


func times(_ times: Int, block: BasicBlock) {
    times_(times) { (_: Int) in block() }
}

func profiler(_ message: String = "") -> BasicBlock {
    let start = Date()
    print("--------- PROFILING \(message)...")
    return {
        print("--------- PROFILING \(message): \(Date().timeIntervalSince(start))")
    }
}

func profiler(_ message: String = "", block: BasicBlock) {
    let p = profiler(message)
    block()
    p()
}

func times(_ times: Int, block: TakesIndexBlock) {
    times_(times, block: block)
}

private func times_(_ times: Int, block: TakesIndexBlock) {
    if times <= 0 {
        return
    }
    for i in 0 ..< times {
        block(i)
    }
}

// this is similar to after(x), but instead of passing in an int, two closures
// are returned.  The first (often called 'afterAll') should be *called*
// everywhere a callback is expected.  The second (often called 'done') should
// be called once, after all the callbacks have been registered. e.g.
//
// func networkCalls(completion: BasicBlock) {
//     let (afterAll, done) = afterN() { completion() }
//     backgroundProcess1(completion: afterAll())
//     backgroundProcess2(completion: afterAll())
//     done()  // this doesn't execute the callback, just says "i'm done registering callbacks"
// }
//
// without this 'done' trick, there is a bug where if the first process is synchronous, the 'count'
// is incremented (by calling 'afterAll') and then immediately decremented.
func afterN(_ block: @escaping BasicBlock) -> (AfterBlock, BasicBlock) {
    var count = 0
    var called = false
    let decrementCount: BasicBlock = {
        count -= 1
        if count == 0 && !called {
            block()
            called = true
        }
    }
    let incrementCount: () -> BasicBlock = {
        count += 1
        return decrementCount
    }
    return (incrementCount, incrementCount())
}

func after(_ times: Int, block: @escaping BasicBlock) -> BasicBlock {
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

func until(_ times: Int, block: @escaping BasicBlock) -> BasicBlock {
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

func once(_ block: @escaping BasicBlock) -> BasicBlock {
    return until(1, block: block)
}

func inBackground(_ block: @escaping BasicBlock) {
    if AppSetup.sharedState.isTesting {
        block()
    }
    else {
        DispatchQueue.global(qos: .default).async(execute: block)
    }
}

func inForeground(_ block: @escaping BasicBlock) {
    nextTick(block)
}

func nextTick(_ block: @escaping BasicBlock) {
    if AppSetup.sharedState.isTesting {
        if Thread.isMainThread {
            block()
        }
        else {
            DispatchQueue.main.sync(execute: block)
        }
    }
    else {
        nextTick(DispatchQueue.main, block: block)
    }
}

func nextTick(_ on: DispatchQueue, block: @escaping BasicBlock) {
    on.async(execute: block)
}

func timeout(_ duration: TimeInterval, block: @escaping BasicBlock) -> BasicBlock {
    let handler = once(block)
    _ = delay(duration) {
        handler()
    }
    return handler
}

func delay(_ duration: TimeInterval, background: Bool = false, block: @escaping BasicBlock) {
    let killTimeOffset = Int64(CDouble(duration) * CDouble(NSEC_PER_SEC))
    let killTime = DispatchTime.now() + Double(killTimeOffset) / Double(NSEC_PER_SEC)
    let queue: DispatchQueue = background ? .global(qos: .background) : .main
    queue.asyncAfter(deadline: killTime, execute: block)
}

func cancelableDelay(_ duration: TimeInterval, block: @escaping BasicBlock) -> BasicBlock {
    let killTimeOffset = Int64(CDouble(duration) * CDouble(NSEC_PER_SEC))
    let killTime = DispatchTime.now() + Double(killTimeOffset) / Double(NSEC_PER_SEC)
    var cancelled = false
    DispatchQueue.main.asyncAfter(deadline: killTime) {
        if !cancelled { block() }
    }
    return { cancelled = true }
}

func debounce(_ timeout: TimeInterval, block: @escaping BasicBlock) -> BasicBlock {
    var timer: Timer? = nil
    let proc = Proc(block)

    return {
        if let prevTimer = timer {
            prevTimer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: timeout, target: proc, selector: #selector(Proc.run), userInfo: nil, repeats: false)
    }
}

func debounce(_ timeout: TimeInterval) -> ThrottledBlock {
    var timer: Timer? = nil

    return { block in
        if let prevTimer = timer {
            prevTimer.invalidate()
        }
        let proc = Proc(block)
        timer = Timer.scheduledTimer(timeInterval: timeout, target: proc, selector: #selector(Proc.run), userInfo: nil, repeats: false)
    }
}
