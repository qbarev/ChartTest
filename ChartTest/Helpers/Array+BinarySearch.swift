import Foundation

extension Array {

    /// Returns the index of the element nearest to `target` using binary search.
    /// The array must be sorted by the value returned from `keyPath`.
    func nearestIndex<T: Comparable & SignedNumeric>(
        to target: T,
        by keyPath: KeyPath<Element, T>
    ) -> Int? {
        guard !isEmpty else { return nil }

        var lo = 0
        var hi = count - 1

        while lo < hi {
            let mid = (lo + hi) / 2
            if self[mid][keyPath: keyPath] < target {
                lo = mid + 1
            } else {
                hi = mid
            }
        }

        if lo > 0 && abs(self[lo - 1][keyPath: keyPath] - target) < abs(self[lo][keyPath: keyPath] - target) {
            return lo - 1
        }
        return lo
    }
}
