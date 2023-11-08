//
//  LogCache.swift
//  LoginputEngineLib
//
//  Created by R0uter on 1/6/21.
//

import Foundation

public class LogCache<K:Hashable,V> {
    private var cache:[K:V] = [:]
    private let queue = DispatchQueue(label: "LogCacheQueue", qos: .userInteractive, attributes: .concurrent)
    
    public init() {
        
    }
    
    public subscript(_ key:K) ->V? {
        get {
            queue.sync {
                return self.cache[key]
            }
            
        }
        set {
            queue.async(flags: .barrier) {
                self.cache[key] = newValue
            }
        }
    }
    
    public func clear() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}
