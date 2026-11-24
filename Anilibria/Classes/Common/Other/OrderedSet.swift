//
//  OrderedSet.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.09.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct OrderedSet<T: Hashable>: ExpressibleByArrayLiteral, Hashable {
    public typealias ArrayLiteralElement = T

    private let orderedSet: NSMutableOrderedSet

    public var array: [T] { Array(orderedSet) as? [T] ?? [] }

    public var first: T? { orderedSet.firstObject as? T }
    
    public var last: T? { orderedSet.lastObject as? T }

    public var count: Int { orderedSet.count }

    public var isEmpty: Bool { count == 0 }

    public init() {
        orderedSet = NSMutableOrderedSet()
    }

    public init<C: Collection<T>>(_ collection: C) {
        orderedSet = NSMutableOrderedSet(array: Array(collection))
    }

    public init(arrayLiteral elements: T...) {
        orderedSet = NSMutableOrderedSet(array: elements)
    }

    public func contains(_ item: T) -> Bool {
        orderedSet.contains(item)
    }

    public mutating func removeAll() {
        orderedSet.removeAllObjects()
    }

    public mutating func remove(_ item: T) {
        orderedSet.remove(item)
    }

    public mutating func append(_ item: T) {
        orderedSet.addObjects(from: [item])
    }

    public mutating func append<C: Collection<T>>(_ collection: C) {
        orderedSet.addObjects(from: Array(collection))
    }

    public mutating func insert(_ item: T, at index: Int) {
        orderedSet.insert(item, at: index)
    }
    
    public mutating func move(_ item: T, to index: Int) {
        remove(item)
        insert(item, at: index)
    }
}

public extension Array where Element: Hashable  {
    init(_ orderedSet: OrderedSet<Element>) {
        self = orderedSet.array
    }
}

