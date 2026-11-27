import MisotoComponents
import Testing

@MainActor
struct ToastCenterTests {
    @Test func queuesMessagesAppliesDurationsAndRunsUndo() {
        let center = ToastCenter()
        #expect(center.current == nil)

        var undone = false
        center.show("Deleted item") { undone = true }
        center.show("Next item", isVoiceOverRunning: true)

        #expect(center.current?.text == "Deleted item")
        #expect(center.current?.duration == ToastTiming.undoDuration)
        #expect(center.queue.count == 1)
        #expect(center.queue[0].duration == ToastTiming.voiceOverDuration)

        center.pause()
        #expect(center.isPaused)
        center.resume()
        #expect(!center.isPaused)

        center.triggerUndo()
        #expect(undone)
        #expect(center.current?.text == "Next item")
        #expect(center.queue.isEmpty)

        center.dismiss()
        #expect(center.current == nil)
    }

    @Test func shortToastUsesThreeSecondDefault() {
        let message = ToastMessage(text: "Saved")
        #expect(message.duration == ToastTiming.shortDuration)
    }
}
