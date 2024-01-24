//
//  StepData.Content.swift
//  keepers-tech-demo
//
//  Created by hung on 1/22/24.
//

extension demoApp {
    static let stepData: [Step: StepData] = [
        .welcomeAbstract: .init(
            title: "dreaming of a modern virtual pet",
            body: """
            I dream of a virtual pet friend experience for the modern day. Virtual pets can be so much more than video games, and yet existing ones still have hunger and happiness progress bars. I want a virtual pet that feels real — one that can interact with me and with the world.

            This app is a quick tech demo of what a virtual pet in 2024 on the Apple Vision Pro could look like.
            """,
            buttons: .standard),
        .volumeIntro: .init(
            title: "always present",
            body: """
            First, your pet should always be in your environment. Would your cat send you a notification whenever it needs attention? Mine would just wake up and sit on my keyboard.

            This non-square critter that represents a possible virtual pet for this demo. Take your pick:
            """,
            buttons: [.standard, .names]),
        .immersiveIntro: .init(
            title: "everywhere all at once",
            body: """
            Once your critter, %@, does have your attention, there are no bounds. It should be able to go anywhere it wants. Imagination’s the limit.
            """,
            buttons: .standard),
        .soundAnalyserIntro: .init(
            title: "all ears",
            body: """
            %@ can understand what it’s hearing and maybe even act on it. Try making or playing some sounds!
            """,
            buttons: [.standard, .micPermissions]),
        .meshClassificationIntro: .init(
            title: "seeing is believing",
            body: """
            It doesn’t stop there. %@ can understand the basic shape of your environment too.

            And it definitely sees you. Btw, does your index finger have something on it?
            """,
            buttons: [.standard, .arPermissions]),
        .futureDevelopment: .init(
            title: "are dreams just memes?",
            body: """
            Unfortunately, that’s all that %@ knows.

            For now.

            With enough development resources, it would be able to learn your habits, how you like to show affection, or what tricks it needs to learn to get the best treats. And so much more.

            Send [@nth_ami](https://twitter.com/intent/user?screen_name=nth_ami) a follow on Twitter to let me know you’re interested. Alternatively, you can press the thumbs up button. If there’s no interest, maybe it’s time I find a job again…
            """,
            buttons: [.previous, .goToControls, .showInterest]),
        .controls: .init(
            title: "",
            body: "",
            buttons: [.showInterest, .restart])
    ]
}
