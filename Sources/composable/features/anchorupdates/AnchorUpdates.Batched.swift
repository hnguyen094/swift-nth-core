//
//  AnchorUpdates.Batched.swift
//  worlds
//
//  Created by Hung Nguyen on 3/13/25.
//

#if os(visionOS)
import ComposableArchitecture
import ARKit
import NthCommon

extension AnchorUpdates {
    @Reducer
    public struct Batched {
        public init() { }

        public struct State: Equatable, AnchorUpdatesState {
            public let options: Options
            @ForceEquatable public var provider: ProviderType
            public init(options: Options, provider: ProviderType) {
                self.options = options
                self.provider = provider
            }
        }

        public enum Action: AnchorUpdatesAction {
            case updates
            case anchorsUpdated(TimedBatch)

            static func anchorUpdates(
                _ updates: AnchorUpdateSequence<ProviderType.AnchorType>,
                options: Options,
                send: Send<Self>
            ) async {
                var batch = switch options {
                case .time(let duration): TimedBatch(duration: duration)
                @unknown default: fatalError()
                }
                for await update in updates {
                    if !batch.update(update) {
                        await send(.anchorsUpdated(batch))
                        batch.reset(adding: update)
                    }
                }
                await send(.anchorsUpdated(batch))
            }
        }

        public func reduce(into state: inout State, action: Action) -> Effect<Action> {
            switch action {
            case .updates:
                return .run { [options = state.options, provider = state.provider] send in
                    await Action.anchorUpdates(provider.anchorUpdates, options: options, send: send)
                }
            default:
                return .none
            }
        }
    }
}

public extension AnchorUpdates.Batched {
    enum Options: Equatable, Sendable {
        case time(duration: TimeInterval)
    }

    struct TimedBatch: Sendable {
        public let duration: TimeInterval

        public var updates: [AnchorUpdate<ProviderType.AnchorType>] = .init()

        /// - Returns: If the update was successful. The update will only fail if the batch is full.
        mutating func update(_ update: AnchorUpdate<ProviderType.AnchorType>) -> Bool {
            if let start = updates.first?.timestamp, update.timestamp > start + duration {
                return false
            }
            updates.append(update)
            return true
        }

        /// Empties out the batch. Optionally allows for setting the first value also for convenience.
        mutating func reset(adding update: AnchorUpdate<ProviderType.AnchorType>? = .none) {
            updates = .init()
            if let validUpdate = update {
                updates.append(validUpdate)
            }
        }
    }
}
#endif
