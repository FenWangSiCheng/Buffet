import Foundation

typealias GCDDelayTask = @MainActor (_ cancel: Bool) -> Void

@MainActor
func delay(_ time: TimeInterval, task: @escaping @MainActor () -> Void) -> GCDDelayTask? {
    var pendingTask: (@MainActor () -> Void)? = task
    let delayedTask: GCDDelayTask = { cancel in
        let action = pendingTask
        pendingTask = nil
        if !cancel {
            action?()
        }
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + time) {
        delayedTask(false)
    }
    return delayedTask
}

@MainActor
func cancel(_ task: GCDDelayTask?) {
    task?(true)
}
