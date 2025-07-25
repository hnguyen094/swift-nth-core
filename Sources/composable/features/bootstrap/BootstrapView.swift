//
//  BootstrapView.swift
//  keepers-tech-demo
//
//  Created by hung on 2/5/24.
//

import SwiftUI
import ComposableArchitecture

public struct BootstrapView<R: Reducer & Sendable, Content: View, PlaceholderContent: View>: View
where R.State: Equatable & Sendable
{
    @Bindable public var store: StoreOf<Bootstrapping<R>>
    public var content: (StoreOf<R>) -> Content
    public var placeholder: (String) -> PlaceholderContent

    @inlinable public init(
        store: StoreOf<Bootstrapping<R>>,
        @ViewBuilder content: @escaping (StoreOf<R>) -> Content,
        @ViewBuilder placeholder: @escaping (_ message: String) -> PlaceholderContent
    ) {
        self.store = store
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        switch store.state {
        case .bootstrapping(let message):
            placeholder(message)
                .onAppear { store.send(.onLaunch) }
        case .bootstrapped:
            if let childStore = store.scope(state: \.bootstrapped, action: \.bootstrapped) {
                content(childStore)
            }
        }
    }
}
