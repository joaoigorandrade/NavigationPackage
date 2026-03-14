import Foundation

@inline(__always)
func assertMainThread(
    _ message: @autoclosure () -> String = "Expected to be on main thread",
    file: StaticString = #file,
    line: UInt = #line
) {
    #if DEBUG
    assert(Thread.isMainThread, message(), file: file, line: line)
    #endif
}
