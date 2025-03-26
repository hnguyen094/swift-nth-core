//
//  AnchorUpdates.swift
//  worlds
//
//  Created by Hung Nguyen on 3/12/25.
//

#if os(visionOS)
import ComposableArchitecture
import ARKit
import NthCommon

public protocol HasAnchorUpdates: DataProvider {
    associatedtype AnchorType: Anchor
    var anchorUpdates: AnchorUpdateSequence<AnchorType> { get }
}

public protocol AnchorUpdatesState {
    associatedtype ProviderType: HasAnchorUpdates
    typealias FilterPredicate = @Sendable
    (AnchorUpdateSequence<ProviderType.AnchorType>.Element) async -> Bool

    var provider: ProviderType { get }
    var filter: FilterPredicate? { get }
}


public protocol AnchorUpdatesAction: Sendable {
    static var updates: Self { get }
}

extension BarcodeDetectionProvider: HasAnchorUpdates { }
extension EnvironmentLightEstimationProvider: HasAnchorUpdates { }
extension HandTrackingProvider: HasAnchorUpdates { }
extension ImageTrackingProvider: HasAnchorUpdates { }
extension ObjectTrackingProvider: HasAnchorUpdates { }
extension PlaneDetectionProvider: HasAnchorUpdates { }
extension RoomTrackingProvider: HasAnchorUpdates { }
extension SceneReconstructionProvider: HasAnchorUpdates { }
extension WorldTrackingProvider: HasAnchorUpdates { }

@Reducer
public struct AnchorUpdates<ProviderType: HasAnchorUpdates> {
    public init() { }

    public struct State: Equatable, AnchorUpdatesState {
        @ForceEquatable public var provider: ProviderType
        @ForceEquatable public var filter: FilterPredicate?

        public init(
            provider: ProviderType,
            filter: FilterPredicate? = .none
        ) {
            self.provider = provider
            self.filter = filter
        }
    }
    public enum Action: AnchorUpdatesAction {
        case updates
        case anchorUpdated(AnchorUpdate<ProviderType.AnchorType>)

        static func anchorUpdates(
            _ updates: some AsyncSequence<AnchorUpdate<ProviderType.AnchorType>, Never>,
            send: Send<Self>
        ) async {
            for await update in updates {
                await send(.anchorUpdated(update))
            }
        }
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .updates:
            return .run { [provider = state.provider, filter = state.filter] send in
                let updates = provider.anchorUpdates
                switch filter {
                case .some(let validFilter):
                    await Action.anchorUpdates(updates.filter(validFilter), send: send)
                case .none:
                    await Action.anchorUpdates(updates, send: send)
                }
            }
        default:
            return .none
        }
    }
}
#endif
