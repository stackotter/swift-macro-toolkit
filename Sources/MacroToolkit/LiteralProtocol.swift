public protocol LiteralProtocol: ExpressionProtocol {
    associatedtype Value
    var value: Value { get }
}
