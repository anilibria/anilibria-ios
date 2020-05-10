final class IdPaging: Paging {
    typealias Value = Int?

    var first: Int?
    var current: Int? = 1

    private let nextIdFactory: Factory<Int?>

    init(nextIdFactory: @escaping Factory<Int?>) {
        self.nextIdFactory = nextIdFactory
    }

    func next() -> Int? {
        return self.nextIdFactory()
    }

    func turnNext() {
        self.current = self.next()
    }

    func reset() {
        self.current = self.first
    }
}
