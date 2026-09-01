// macOS 화면 좌표에 진짜 마우스 클릭을 보낸다 (시뮬레이터 창의 두 번 탭·연타용).
//   swiftc -O dclick.swift -o dclick
//   dclick <x> <y> [count=2] [gapMs=80]
import CoreGraphics
import Foundation

let a = CommandLine.arguments
guard a.count >= 3, let x = Double(a[1]), let y = Double(a[2]) else {
    FileHandle.standardError.write("usage: dclick <x> <y> [count=2] [gapMs=80]\n".data(using: .utf8)!)
    exit(2)
}
let p = CGPoint(x: x, y: y)
let n = a.count > 3 ? Int(a[3]) ?? 2 : 2
let gap = a.count > 4 ? UInt32(a[4]) ?? 80 : 80
for i in 1...n {
    for type in [CGEventType.leftMouseDown, .leftMouseUp] {
        let e = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: p, mouseButton: .left)!
        e.setIntegerValueField(.mouseEventClickState, value: Int64(i))
        e.post(tap: .cghidEventTap)
        usleep(15_000)
    }
    if i < n { usleep(gap * 1000) }
}
