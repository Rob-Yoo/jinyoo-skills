// 임시 계측: 메인 스레드 프레임 콜백 간격이 기준을 넘으면 태그 로그를 남긴다.
// Instruments 없이 hang 을 루프로 만드는 가벼운 probe 다.
//
// 쓰는 법: 이 파일을 앱 타깃에 복사하고 앱 시작 시 한 번 부른다.
//     MainThreadGapProbe.start(tag: "[DEBUG-a4f2]")
// 출력 예: "[DEBUG-a4f2] main-thread gap 183ms at 12.408"
// 진단이 끝나면 파일과 호출을 지운다 (Phase 6).
//
// CADisplayLink 를 .common 모드에 걸어 스크롤 중 (tracking 모드) 에도 잰다.
import UIKit

@MainActor
final class MainThreadGapProbe: NSObject {
    private static var current: MainThreadGapProbe?

    private let tag: String
    private let threshold: CFTimeInterval
    private var lastTimestamp: CFTimeInterval = 0

    static func start(tag: String, thresholdMilliseconds: Double = 50) {
        let probe = MainThreadGapProbe(tag: tag, threshold: thresholdMilliseconds / 1000)
        CADisplayLink(target: probe, selector: #selector(tick(_:))).add(to: .main, forMode: .common)
        current = probe
    }

    private init(tag: String, threshold: CFTimeInterval) {
        self.tag = tag
        self.threshold = threshold
    }

    @objc private func tick(_ link: CADisplayLink) {
        let now = link.timestamp
        if lastTimestamp > 0, now - lastTimestamp > threshold {
            print("\(tag) main-thread gap \(Int((now - lastTimestamp) * 1000))ms at \(String(format: "%.3f", now))")
        }
        lastTimestamp = now
    }
}
