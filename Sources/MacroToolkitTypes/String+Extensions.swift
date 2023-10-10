extension String {
    /// The string but with its first character uppercased.
    public var initialUppercased: String {
        guard let initial = first else {
            return self
        }

        return "\(initial.uppercased())\(dropFirst())"
    }
}
