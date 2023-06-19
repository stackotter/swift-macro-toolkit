public protocol LiteralProtocol: ExprProtocol {
    associatedtype Value
    var value: Value { get }
}
