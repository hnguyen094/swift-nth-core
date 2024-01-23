//
//  TypeText.swift
//  keepers-tech-demo
//
//  Created by hung on 1/20/24.
//
//  Modified copy of HelloWorld's version.

import SwiftUI
import Combine

extension View {
    /// Makes the specified text appear one letter at a time.
    func typeText(
        text: Binding<String>,
        finalText: String?,
        cursor: String = "|",
        isAnimated: Bool = true,
        isFinished: Binding<Bool>? = .none,
        speed: UInt64 = 100
    ) -> some View {
        self.modifier(
            TypeTextModifier(
                text: text,
                finalText: finalText,
                cursor: cursor,
                isAnimated: isAnimated,
                isFinished: isFinished ?? Binding.constant(true),
                speed: speed
            )
        )
    }
}

private struct TypeTextModifier: ViewModifier {
    @Binding var text: String
    var finalText: String?
    var cursor: String
    var isAnimated: Bool
    @Binding var isFinished: Bool
    var speed: UInt64
    
    @State private var animationTask: AnyCancellable? = .none

    func body(content: Content) -> some View {
        content
            .onChange(of: finalText, initial: true) {
                isFinished = false
                if let runningTask = animationTask {
                    runningTask.cancel()
                    animationTask = .none
                }
                
                guard let finalText = finalText else {
                    text = ""
                    isFinished = true
                    return
                }
                if isAnimated == false || finalText == text {
                    text = finalText
                    isFinished = true
                    return
                }
                
                animationTask = Task {
                    do {
                        let startText = text
                        
                        // Blink the cursor a few times.
                        for _ in 0..<2 {
                            text = startText + cursor
                            try await Task.sleep(for: .milliseconds(500))
                            text = startText
                            try await Task.sleep(for: .milliseconds(200))
                        }
                        
                        // Delete the old text.
                        for index in startText.indices.reversed() {
                            text = String(startText.prefix(through: index)) + cursor
                            let milliseconds = (1 + UInt64.random(in: 0 ... 1)) * speed / 2
                            try await Task.sleep(for: .milliseconds(milliseconds))
                        }
                        text = ""
                        try await Task.sleep(for: .milliseconds(2 * speed))
                        
                        // Type out the text.
                        for index in finalText.indices {
                            text = String(finalText.prefix(through: index)) + cursor
                            let milliseconds = (1 + UInt64.random(in: 0 ... 1)) * speed
                            try await Task.sleep(for: .milliseconds(milliseconds))
                        }
                        
                        // Blink the cursor a few times.
                        for _ in 0..<2 {
                            text = finalText + cursor
                            try await Task.sleep(for: .milliseconds(500))
                            text = finalText
                            try await Task.sleep(for: .milliseconds(200))
                        }
//                        
//                        // Wrap up the animation.
//                        try await Task.sleep(for: .milliseconds(4 * speed))
                        text = finalText
                        isFinished = true
                    } catch is CancellationError {
                        text = ""
                    }
                }.eraseToAnyCancellable()
            }
    }
}
