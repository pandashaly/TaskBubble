import SwiftUI

class MotivationalService: ObservableObject {
    @Published var currentMessage: String = ""
    private var timer: Timer?
    
    // Store counts to allow cycleMessage to generate dynamic messages
    private var lastCompleted: Int = 0
    private var lastRemaining: Int = 0
    
    private let generalMessages = [
        "Every step counts – keep moving forward!",
        "Small wins lead to big victories!",
        "You’re doing amazing – don’t stop now!",
        "One task at a time, one victory at a time.",
        "Focus. Finish. Flourish.",
        "Progress over perfection!",
        "Your hard work is paying off!",
        "Keep going – your future self will thank you!",
        "Tasks are tough, but so are you!",
        "Stay productive, stay awesome!",
        "Keep the streak alive – you’re unstoppable!",
        "One more task – and you crush it!",
        "Small steps build momentum – keep at it!",
        "Dream big. Start small. Avoid crying too much.",
        "Consistency > inspiration. Keep showing up.",
        "The best project you’ll ever work on is yourself.",
        "Stop worrying. Start doing. Repeat.",
        "Goals don’t care about feelings. Do the work anyway.",
        "You didn’t wake up to be mediocre.",
        "You’re not a cactus. Drink some water.",
        "Water check! Your brain is thirsty.",
        "Hydration = productivity. Don’t cheat yourself.",
        "Tasks hate you. You hate tasks. Its a toxic relationship but it works.",
        "You didn’t come this far to leave things unfinished.",
        "One task today keeps the anxiety away… maybe.",
        "One box ticked = one existential crisis avoided.",
        "Tasks aren’t gonna do themselves.",
        "Stop scrolling TikTok. Start checking boxes.",
        "You got this… probably. Just maybe. Okay, do it.",
        "Would your future self be proud of you? No? Keep working.",
        "Adulting is hard. Tasks make it harder. Do them anyway.",
        "You can’t nap your way to success… just take it one task at a time.",
        "Life hack: crossing things off your list is cheaper than therapy.",
        "Tasks don’t care about your mood. Do them anyway.",
        "You deserve a snack.",
        "But did you drink water though?"
    ]
    
    init() {
        updateMessage(completed: 0, remaining: 0)
        startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        // Cycle every 120 seconds (2 minutes)
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.cycleMessage()
        }
    }
    
    private func cycleMessage() {
        updateMessage(completed: lastCompleted, remaining: lastRemaining)
    }
    
    func updateMessage(completed: Int, remaining: Int) {
        self.lastCompleted = completed
        self.lastRemaining = remaining
        
        var pool: [String] = []
        
        if remaining > 0 || completed > 0 {
            pool = [
                "You’ve completed \(completed) tasks today – keep it going!",
                "You've completed \(completed) tasks today! Look at you adulting!",
                "You checked off \(completed) tasks! I think you deserve a snack!",
                "Only \(remaining) tasks left – you got this!",
                "\(completed) tasks done – feeling unstoppable!",
                "Great work! \(completed) tasks crossed off!",
                "\(remaining) tasks to go – finish strong!",
                "Keep rolling – \(completed) down, \(remaining) to go!",
                "Your productivity is shining: \(completed) tasks done!",
                "Almost there! Just \(remaining) tasks remaining!",
                "YAY! \(completed) tasks completed! celebrate small wins!",
                "\(remaining) tasks left, one step at a time."
            ]
        }
        
        pool.append(contentsOf: generalMessages)
        
        withAnimation(.easeInOut(duration: 1.0)) {
            currentMessage = pool.randomElement() ?? ""
        }
    }
}

//TO DO - fix cycle msg time
