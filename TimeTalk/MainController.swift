import UIKit
import AVFoundation


private let calendar = NSCalendar.currentCalendar()
private var synthesizer = AVSpeechSynthesizer()
private var voice = AVSpeechSynthesisVoice(language: "en-US")


class MainController: UIViewController {
    @IBOutlet var timeLabel: UILabel!
    var started = false
    var timer: CancelableTimer!
    var previousMinute = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Don't allow automatic screen lock to occur while this app is active.
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        updateTimeLabel()
        
        timer = CancelableTimer(once: false, handler: updateTimeLabel)
        timer.startWithInterval(1.0)
    }
    
    @IBAction func startOrStop(sender: UIButton) {
        started = !started
        sender.setTitle(started ? "Stop" : "Start", forState: .Normal)
        if started {
            let (hour, minute) = getHourAndMinute()
            speakHour(hour, andMinute: minute)
        }
    }
    
    func updateTimeLabel() {
        let (hour, minute) = getHourAndMinute()
        if previousMinute != minute {
            previousMinute = minute
            timeLabel.text = String(format: "%02d:%02d", hour, minute)
            
            if started {
                speakHour(hour, andMinute: minute)
            }
        }
    }
}


func speak(text: String) {
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = voice
    // Interrupt any phrase that's currently being spoken.
    if synthesizer.speaking {
        synthesizer.stopSpeakingAtBoundary(.Immediate)
    }
    synthesizer.speakUtterance(utterance)
}

func speakHour(hour: Int, andMinute minute: Int) {
    let text = (minute < 10) ?
        "\(hour) O \(minute)" : "\(hour) \(minute)"
    speak(text)
}

func getHourAndMinute() -> (Int, Int) {
    let now = NSDate()
    let comp = calendar.components([.Hour, .Minute], fromDate: now)
    let hour = comp.hour % 12
    let minute = comp.minute
    return (hour, minute)
}