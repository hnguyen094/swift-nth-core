import Foundation

// Best used when scoping to a store that has a Never action type.
func absurd<A>(_: Never) -> A { }
