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
            This demo is the beginning of a virtual pet experience that I want to make.
            Virtual pets can be so much more than video games, and yet existing ones still have hunger and happiness progress bars. I want a friend (ami) that I can create an emotional connection with, and one that can interact with me and the world.

            This is an (incomplete) tech demo to demonstrate some what is possible. It is also a step towards making a virtual pet game that I would enjoy playing myself.
            """,
            buttons: .standard),
        .volumeIntro: .init(
            title: "always present",
            body: """
            Virtual pets on smartphones require you to turn on your screen to see it. Using volumes, your pet should always be one look away. My cat wouldn't send me a notification if it wants food, and neither should this one.

            Pick a name, then press the button to show your non-square critter:
            """,
            buttons: [.standard, .names]),
        .immersiveIntro: .init(
            title: "everywhere all at once",
            body: """
            When you give your critter %@ your attention, it doesn't have to be bound to the window volume.
            The system provides information about surfaces such as such as ceilings, tables, walls, etc. This would allow %@ to choose to sleep on the couch or have a favorite spot in the corner.
            """,
            buttons: .standard),
        .soundAnalyserIntro: .init(
            title: "all ears",
            body: """
            In addition, we can run many different machine learning/artificial intelligence algorithms. Here is one provided by Apple to recognize up to 300 different sounds. Give it a try!
            """,
            buttons: [.standard, .micPermissions]),
        .meshClassificationIntro: .init(
            title: "seeing is believing",
            body: """
            It doesn’t stop there. %@ can understand the complex geometry of your environment too. It can recognize TVs, plants, and home applicances with physics. It can also see you and your hands too.
            """,
            buttons: [.standard, .arPermissions]),
        .futureDevelopment: .init(
            title: "are my dreams just memes?",
            body: """
            There's so much more that %@ can know. But I'm not there yet.
            
            I want the critter to be all that a pet should be. In the era of machine learning, critter %@ should at least be able to learn tricks, get used to your habits, and play favorites with their humans. Those are some of the things I want to build, on top of all the other obvious things missing from this (art, sound, basic food cycle.) And I think I have the technical know-how to make it happen.
            
            But that won't possible unless there's interest. You can either follow [@nth_ami](https://twitter.com/intent/user?screen_name=nth_ami) or press the thumbs up button (as many times as you'd like) below. I want to make this idea a reality.
            """,
            buttons: [.previous, .goToControls, .showInterest]),
        .controls: .init(
            title: "",
            body: "",
            buttons: [.showInterest, .restart])
    ]
}
