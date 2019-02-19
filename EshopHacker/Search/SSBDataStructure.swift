//
//  Trie.swift
//  
//
//  Created by Jiang,Zhenhua on 2019/2/3.
//


import Foundation

/// A node in the trie
class SSBTrieNode<T: Hashable> {
    var value: T?
    weak var parentNode: SSBTrieNode?
    var children: [T: SSBTrieNode] = [:]
    var isTerminating = false
    var isLeaf: Bool {
        return children.count == 0
    }
    
    /// Initializes a node.
    ///
    /// - Parameters:
    ///   - value: The value that goes into the node
    ///   - parentNode: A reference to this node's parent
    init(value: T? = nil, parentNode: SSBTrieNode? = nil) {
        self.value = value
        self.parentNode = parentNode
    }
    
    /// Adds a child node to self.  If the child is already present,
    /// do nothing.
    ///
    /// - Parameter value: The item to be added to this node.
    func add(value: T) {
        guard children[value] == nil else {
            return
        }
        children[value] = SSBTrieNode(value: value, parentNode: self)
    }
}

/// A trie data structure containing words.  Each node is a single
/// character of a word.
class SSBTrie: NSObject, NSCoding {
    typealias Node = SSBTrieNode<Character>
    /// The number of words in the trie
    public var count: Int {
        return wordCount
    }
    /// Is the trie empty?
    public var isEmpty: Bool {
        return wordCount == 0
    }
    /// All words currently in the trie
    public var words: [String] {
        return wordsInSubtrie(rootNode: root, partialWord: "")
    }
    fileprivate let root: Node
    fileprivate var wordCount: Int
    
    /// Creates an empty trie.
    override init() {
        root = Node()
        wordCount = 0
        super.init()
    }
    
    // MARK: NSCoding
    /// Initializes the trie with words from an archive
    ///
    /// - Parameter decoder: Decodes the archive
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        guard let words = decoder.decodeObject(forKey: "words") as? [String] else {
            return
        }
        words.forEach { self.insert(word: $0) }
    }
    
    /// Encodes the words in the trie by putting them in an array then encoding
    /// the array.
    ///
    /// - Parameter coder: The object that will encode the array
    func encode(with coder: NSCoder) {
        coder.encode(words, forKey: "words")
    }
    
    subscript(prefix: String) -> [String] {
        get {
            return findWordsWithPrefix(prefix: prefix)
        }
    }
}


// MARK: - Adds methods: insert, remove, contains
extension SSBTrie {
    /// Inserts a word into the trie.  If the word is already present,
    /// there is no change.
    ///
    /// - Parameter word: the word to be inserted.
    func insert(word: String) {
        guard !word.isEmpty else {
            return
        }
        var currentNode = root
        for character in word.lowercased() {
            if let childNode = currentNode.children[character] {
                currentNode = childNode
            } else {
                currentNode.add(value: character)
                currentNode = currentNode.children[character]!
            }
        }
        // Word already present?
        guard !currentNode.isTerminating else {
            return
        }
        wordCount += 1
        currentNode.isTerminating = true
    }
    
    /// Determines whether a word is in the trie.
    ///
    /// - Parameter word: the word to check for
    /// - Returns: true if the word is present, false otherwise.
    func contains(word: String) -> Bool {
        guard !word.isEmpty else {
            return false
        }
        var currentNode = root
        for character in word.lowercased() {
            guard let childNode = currentNode.children[character] else {
                return false
            }
            currentNode = childNode
        }
        return currentNode.isTerminating
    }
    
    /// Attempts to walk to the last node of a word.  The
    /// search will fail if the word is not present. Doesn't
    /// check if the node is terminating
    ///
    /// - Parameter word: the word in question
    /// - Returns: the node where the search ended, nil if the
    /// search failed.
    private func findLastNodeOf(word: String) -> Node? {
        var currentNode = root
        for character in word.lowercased() {
            guard let childNode = currentNode.children[character] else {
                return nil
            }
            currentNode = childNode
        }
        return currentNode
    }
    
    /// Attempts to walk to the terminating node of a word.  The
    /// search will fail if the word is not present.
    ///
    /// - Parameter word: the word in question
    /// - Returns: the node where the search ended, nil if the
    /// search failed.
    private func findTerminalNodeOf(word: String) -> Node? {
        if let lastNode = findLastNodeOf(word: word) {
            return lastNode.isTerminating ? lastNode : nil
        }
        return nil
    }
    
    /// Deletes a word from the trie by starting with the last letter
    /// and moving back, deleting nodes until either a non-leaf or a
    /// terminating node is found.
    ///
    /// - Parameter terminalNode: the node representing the last node
    /// of a word
    private func deleteNodesForWordEndingWith(terminalNode: Node) {
        var lastNode = terminalNode
        var character = lastNode.value
        while lastNode.isLeaf, let parentNode = lastNode.parentNode {
            lastNode = parentNode
            lastNode.children[character!] = nil
            character = lastNode.value
            if lastNode.isTerminating {
                break
            }
        }
    }
    
    /// Removes a word from the trie.  If the word is not present or
    /// it is empty, just ignore it.  If the last node is a leaf,
    /// delete that node and higher nodes that are leaves until a
    /// terminating node or non-leaf is found.  If the last node of
    /// the word has more children, the word is part of other words.
    /// Mark the last node as non-terminating.
    ///
    /// - Parameter word: the word to be removed
    func remove(word: String) {
        guard !word.isEmpty else {
            return
        }
        guard let terminalNode = findTerminalNodeOf(word: word) else {
            return
        }
        if terminalNode.isLeaf {
            deleteNodesForWordEndingWith(terminalNode: terminalNode)
        } else {
            terminalNode.isTerminating = false
        }
        wordCount -= 1
    }
    
    /// Returns an array of words in a subtrie of the trie
    ///
    /// - Parameters:
    ///   - rootNode: the root node of the subtrie
    ///   - partialWord: the letters collected by traversing to this node
    /// - Returns: the words in the subtrie
    fileprivate func wordsInSubtrie(rootNode: Node, partialWord: String) -> [String] {
        var subtrieWords = [String]()
        var previousLetters = partialWord
        if let value = rootNode.value {
            previousLetters.append(value)
        }
        if rootNode.isTerminating {
            subtrieWords.append(previousLetters)
        }
        for childNode in rootNode.children.values {
            let childWords = wordsInSubtrie(rootNode: childNode, partialWord: previousLetters)
            subtrieWords += childWords
        }
        return subtrieWords
    }
    
    /// Returns an array of words in a subtrie of the trie that start
    /// with given prefix
    ///
    /// - Parameters:
    ///   - prefix: the letters for word prefix
    /// - Returns: the words in the subtrie that start with prefix
    func findWordsWithPrefix(prefix: String) -> [String] {
        var words = [String]()
        let prefixLowerCased = prefix.lowercased()
        if let lastNode = findLastNodeOf(word: prefixLowerCased) {
            if lastNode.isTerminating {
                words.append(prefixLowerCased)
            }
            for childNode in lastNode.children.values {
                let childWords = wordsInSubtrie(rootNode: childNode, partialWord: prefixLowerCased)
                words += childWords
            }
        }
        return words
    }
}

public final class LinkedList<T> {
    
    public class LinkedListNode<T> {
        var value: T
        var next: LinkedListNode?
        weak var previous: LinkedListNode?
        
        public init(value: T) {
            self.value = value
        }
    }
    
    public typealias Node = LinkedListNode<T>
    
    fileprivate var head: Node?
    
    public init() {}
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public var first: Node? {
        return head
    }
    
    public var last: Node? {
        if var node = head {
            while let next = node.next {
                node = next
            }
            return node
        } else {
            return nil
        }
    }
    
    public var count: Int {
        if var node = head {
            var c = 1
            while let next = node.next {
                node = next
                c += 1
            }
            return c
        } else {
            return 0
        }
    }
    
    public func node(atIndex index: Int) -> Node? {
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 { return node }
                i -= 1
                node = node!.next
            }
        }
        return nil
    }
    
    public subscript(index: Int) -> T {
        let node = self.node(atIndex: index)
        assert(node != nil)
        return node!.value
    }
    
    public func append(_ value: T) {
        let newNode = Node(value: value)
        self.append(newNode)
    }
    
    public func append(_ node: Node) {
        let newNode = LinkedListNode(value: node.value)
        if let lastNode = last {
            newNode.previous = lastNode
            lastNode.next = newNode
        } else {
            head = newNode
        }
    }
    
    public func append(_ list: LinkedList) {
        var nodeToCopy = list.head
        while let node = nodeToCopy {
            self.append(node.value)
            nodeToCopy = node.next
        }
    }
    
    private func nodesBeforeAndAfter(index: Int) -> (Node?, Node?) {
        assert(index >= 0)
        
        var i = index
        var next = head
        var prev: Node?
        
        while next != nil && i > 0 {
            i -= 1
            prev = next
            next = next!.next
        }
        assert(i == 0)  // if > 0, then specified index was too large
        return (prev, next)
    }
    
    public func insert(_ value: T, atIndex index: Int) {
        let newNode = Node(value: value)
        self.insert(newNode, atIndex: index)
    }
    
    public func insert(_ node: Node, atIndex index: Int) {
        let (prev, next) = nodesBeforeAndAfter(index: index)
        let newNode = LinkedListNode(value: node.value)
        newNode.previous = prev
        newNode.next = next
        prev?.next = newNode
        next?.previous = newNode
        
        if prev == nil {
            head = newNode
        }
    }
    
    public func insert(_ list: LinkedList, atIndex index: Int) {
        if list.isEmpty { return }
        var (prev, next) = nodesBeforeAndAfter(index: index)
        var nodeToCopy = list.head
        var newNode: Node?
        while let node = nodeToCopy {
            newNode = Node(value: node.value)
            newNode?.previous = prev
            if let previous = prev {
                previous.next = newNode
            } else {
                self.head = newNode
            }
            nodeToCopy = nodeToCopy?.next
            prev = newNode
        }
        prev?.next = next
        next?.previous = prev
    }
    
    public func removeAll() {
        head = nil
    }
    
    @discardableResult public func remove(node: Node) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev
        
        node.previous = nil
        node.next = nil
        return node.value
    }
    
    @discardableResult public func removeLast() -> T {
        assert(!isEmpty)
        return remove(node: last!)
    }
    
    @discardableResult public func remove(atIndex index: Int) -> T {
        let node = self.node(atIndex: index)
        assert(node != nil)
        return remove(node: node!)
    }
}

extension LinkedList: CustomStringConvertible {
    public var description: String {
        var s = "["
        var node = head
        while node != nil {
            s += "\(node!.value)"
            node = node!.next
            if node != nil { s += ", " }
        }
        return s + "]"
    }
}

extension LinkedList {
    public func reverse() {
        var node = head
        while let currentNode = node {
            node = currentNode.next
            swap(&currentNode.next, &currentNode.previous)
            head = currentNode
        }
    }
}

extension LinkedList {
    public func map<U>(transform: (T) -> U) -> LinkedList<U> {
        let result = LinkedList<U>()
        var node = head
        while node != nil {
            result.append(transform(node!.value))
            node = node!.next
        }
        return result
    }
    
    public func filter(predicate: (T) -> Bool) -> LinkedList<T> {
        let result = LinkedList<T>()
        var node = head
        while node != nil {
            if predicate(node!.value) {
                result.append(node!.value)
            }
            node = node!.next
        }
        return result
    }
}

extension LinkedList {
    convenience init(array: Array<T>) {
        self.init()
        
        for element in array {
            self.append(element)
        }
    }
}

extension LinkedList: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: T...) {
        self.init()
        
        for element in elements {
            self.append(element)
        }
    }
}

public class LRUCache<KeyType: Hashable, ValueType> {
    private let maxSize: Int
    private var cache: [KeyType: ValueType] = [:]
    private var priority: LinkedList<KeyType> = LinkedList<KeyType>()
    private var key2node: [KeyType: LinkedList<KeyType>.LinkedListNode<KeyType>] = [:]
    
    public init(_ maxSize: Int) {
        self.maxSize = maxSize
    }
    
    public func get(_ key: KeyType) -> ValueType? {
        guard let val = cache[key] else {
            return nil
        }
        
        remove(key)
        insert(key, val: val)
        
        return val
    }
    
    public func set(_ key: KeyType, val: ValueType) {
        if cache[key] != nil {
            remove(key)
        } else if priority.count >= maxSize, let keyToRemove = priority.last?.value {
            remove(keyToRemove)
        }
        
        insert(key, val: val)
    }
    
    subscript(key: KeyType, val: ValueType?) -> ValueType? {
        get {
            return get(key)
        }
        set {
            guard let value = val else {
                remove(key)
                return
            }
            set(key, val: value)
        }
    }
    
    private func remove(_ key: KeyType) {
        cache.removeValue(forKey: key)
        guard let node = key2node[key] else {
            return
        }
        priority.remove(node: node)
        key2node.removeValue(forKey: key)
    }
    
    private func insert(_ key: KeyType, val: ValueType) {
        cache[key] = val
        priority.insert(key, atIndex: 0)
        guard let first = priority.first else {
            return
        }
        key2node[key] = first
    }
}
