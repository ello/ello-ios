////
///  FreeMethods.swift
//

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


typealias Block = () -> Void
typealias ErrorBlock = (Error) -> Void
typealias BoolBlock = (Bool) -> Void
typealias AfterBlock = () -> Block
typealias ThrottledBlock = (@escaping Block) -> Void
typealias TakesIndexBlock = (Int) -> Void
typealias OnHeightMismatch = (CGFloat) -> Void


// MARK: Animations

struct AnimationOptions {
    let duration: TimeInterval
    let delay: TimeInterval
    let options: UIView.AnimationOptions
}

class AnimationPromise {
    var completionBlock: BoolBlock?
    var alwaysBlock: Block?
    var resolved: Bool?

    func completion(_ block: @escaping BoolBlock) {
        if let resolved = resolved {
            block(resolved)
            return
        }
        completionBlock = block
    }

    func done(_ block: @escaping Block) {
        if resolved != nil {
            block()
            return
        }
        alwaysBlock = block
    }

    func resolve(completed: Bool) {
        resolved = completed
        completionBlock?(completed)
        alwaysBlock?()
    }
}

let DefaultAnimationDuration: TimeInterval = 0.2
let DefaultAppleAnimationDuration: TimeInterval = 0.3

@discardableResult
func animate(
    duration: TimeInterval = DefaultAnimationDuration,
    delay: TimeInterval = 0,
    options: UIView.AnimationOptions = UIView.AnimationOptions(),
    animated: Bool? = nil,
    animations: @escaping Block
) -> AnimationPromise {
    return elloAnimate(
        duration: duration,
        delay: delay,
        options: options,
        animated: animated,
        animations: animations
    )
}

@discardableResult
func animateWithKeyboard(
    animated: Bool? = nil,
    animations: @escaping Block
) -> AnimationPromise {
    return elloAnimate(
        duration: Keyboard.shared.duration,
        options: Keyboard.shared.options,
        animated: animated,
        animations: animations
    )
}

@discardableResult
func elloAnimate(
    duration: TimeInterval = DefaultAnimationDuration,
    delay: TimeInterval = 0,
    options: UIView.AnimationOptions = UIView.AnimationOptions(),
    animated: Bool? = nil,
    animations: @escaping Block
) -> AnimationPromise {
    let shouldAnimate: Bool = animated ?? !Globals.isTesting
    let options = AnimationOptions(duration: duration, delay: delay, options: options)
    return performAnimation(options: options, animated: shouldAnimate, animations: animations)
}

@discardableResult
private func performAnimation(
    options: AnimationOptions,
    animated: Bool = true,
    animations: @escaping Block
) -> AnimationPromise {
    let promise = AnimationPromise()
    if animated {
        UIView.animate(
            withDuration: options.duration,
            delay: options.delay,
            options: options.options,
            animations: animations,
            completion: promise.resolve
        )
    }
    else {
        animations()
        promise.resolve(completed: true)
    }
    return promise
}

class Proc {
    private var block: Block

    init(_ block: @escaping Block) {
        self.block = block
    }

    @objc
    func run() {
        block()
    }
}


func times(_ times: Int, block: Block) {
    times_(times) { (_: Int) in block() }
}

func profiler(_ message: String = "") -> Block {
    let start = Globals.now
    print("--------- PROFILING \(message)...")
    return {
        print("--------- PROFILING \(message): \(Globals.now.timeIntervalSince(start))")
    }
}

func profiler(_ message: String = "", block: Block) {
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
    for i in 0..<times {
        block(i)
    }
}

// this is similar to after(x), but instead of passing in an int, two closures
// are returned.  The first (often called 'afterAll') should be *called*
// everywhere a callback is expected.  The second (often called 'done') should
// be called once, after all the callbacks have been registered. e.g.
//
// func networkCalls(completion: Block) {
//     let (afterAll, done) = afterN { completion() }
//     backgroundProcess1(completion: afterAll())
//     backgroundProcess2(completion: afterAll())
//     done()  // this doesn't execute the callback, just says "i'm done registering callbacks"
// }
//
// without this 'done' trick, there is a bug where if the first process is synchronous, the 'count'
// is incremented (by calling 'afterAll') and then immediately decremented.
func afterN(on queue: DispatchQueue? = nil, execute block: @escaping Block) -> (AfterBlock, Block) {
    var count = 0
    var called = false
    let decrementCount: Block = {
        count -= 1
        if count == 0 && !called {
            if Globals.isTesting, queue == DispatchQueue.main {
                block()
            }
            else if queue == DispatchQueue.main, Thread.isMainThread {
                block()
            }
            else if let queue = queue {
                queue.async(execute: block)
            }
            else {
                block()
            }
            called = true
        }
    }
    let incrementCount: () -> Block = {
        count += 1
        return decrementCount
    }
    return (incrementCount, incrementCount())
}

func after(_ times: Int, block: @escaping Block) -> Block {
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

func until(_ times: Int, block: @escaping Block) -> Block {
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

func once(_ block: @escaping Block) -> Block {
    return until(1, block: block)
}

func inBackground(_ block: @escaping Block) {
    if Globals.isTesting {
        block()
    }
    else {
        DispatchQueue.global(qos: .default).async(execute: block)
    }
}

func inForeground(_ block: @escaping Block) {
    nextTick(block)
}

func nextTick(_ block: @escaping Block) {
    if Globals.isTesting {
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

func nextTick(_ on: DispatchQueue, block: @escaping Block) {
    on.async(execute: block)
}

func timeout(_ duration: TimeInterval, block: @escaping Block) -> Block {
    let handler = once(block)
    _ = delay(duration) {
        handler()
    }
    return handler
}

func delay(_ duration: TimeInterval, background: Bool = false, block: @escaping Block) {
    let killTimeOffset = Int64(CDouble(duration) * CDouble(NSEC_PER_SEC))
    let killTime = DispatchTime.now() + Double(killTimeOffset) / Double(NSEC_PER_SEC)
    let queue: DispatchQueue = background ? .global(qos: .background) : .main
    queue.asyncAfter(deadline: killTime, execute: block)
}

func cancelableDelay(_ duration: TimeInterval, block: @escaping Block) -> Block {
    let killTimeOffset = Int64(CDouble(duration) * CDouble(NSEC_PER_SEC))
    let killTime = DispatchTime.now() + Double(killTimeOffset) / Double(NSEC_PER_SEC)
    var cancelled = false
    DispatchQueue.main.asyncAfter(deadline: killTime) {
        if !cancelled { block() }
    }
    return { cancelled = true }
}

func debounce(_ timeout: TimeInterval, block: @escaping Block) -> Block {
    var timer: Timer?
    let proc = Proc(block)

    return {
        if let prevTimer = timer {
            prevTimer.invalidate()
        }
        timer = Timer.scheduledTimer(
            timeInterval: timeout,
            target: proc,
            selector: #selector(Proc.run),
            userInfo: nil,
            repeats: false
        )
    }
}

func debounce(_ timeout: TimeInterval) -> ThrottledBlock {
    var timer: Timer?

    return { block in
        if let prevTimer = timer {
            prevTimer.invalidate()
        }
        let proc = Proc(block)
        timer = Timer.scheduledTimer(
            timeInterval: timeout,
            target: proc,
            selector: #selector(Proc.run),
            userInfo: nil,
            repeats: false
        )
    }
}

@discardableResult
func every(_ timeout: TimeInterval, _ block: @escaping Block) -> Block {
    let proc = Proc(block)
    let timer = Timer.scheduledTimer(
        timeInterval: timeout,
        target: proc,
        selector: #selector(Proc.run),
        userInfo: nil,
        repeats: true
    )
    return {
        timer.invalidate()
    }
}
