module set

import avl

// Specialisation of AVL trees, used as a set.
pub alias set<a> = avltree<a, bool>

// Empty set.
pub fun empty(): set<a>
  HTip

// Does not insert if the item already exists.
pub fun insert(set: set<a>, x: a, compare: (a, a) -> order): set<a>
  set.avl-insert(x, True, compare)

// Returns false if item not in set.
pub fun contains(set: set<a>, x: a, compare: (a, a) -> order): bool
  set.avl-get(x, False, compare)

// Set union.
pub fun union(l: set<a>, r: set<a>, compare: (a, a) -> order): set<a>
  r.fold(l) fn (k, v, acc) {
    acc.avl-insert(k, v, compare)
  }

// Set intersection.
pub fun intersect(l: set<a>, r: set<a>, compare: (a, a) -> order): set<a>
  l.fold(empty()) fn (k, _, acc) {
    if   r.contains(k, compare)
    then acc.insert(k, compare)
    else acc
  }

// Returns the same set if no item was removed.
pub fun remove(set: set<a>, x: a, compare: (a, a) -> order): pure set<a>
  set.avl-delete(x, compare)

// Get the number of items in the set.
pub fun set-count(set: set<a>): int
  set.count

// Returns any item in the set, usually the set tree's root.
pub fun any(set: set<a>): maybe<(a, bool)>
  set.get-any()
