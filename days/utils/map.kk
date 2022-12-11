module map

import avl
import ord

// AVL trees are already maps, but this will provide a friendlier interface.
pub alias map<k, v> = avltree<k, maybe<v>>

// Empty map.
pub fun empty(): map<k, v>
  HTip

// Replaces the value if the key already exists.
pub fun insert(
  map: map<k, v>,
  key: k, value: v,
  compare: (k, k) -> e order
): e map<k, v>
  map.avl-insert(key, Just(value), compare, True)

pub fun insert(
  map: map<k, v>,
  key: k, value: v
): ord<k> map<k, v>
  map.insert(key, value, cmp)

// Gets the item from the map if it exists. Two versions.
// Returns a maybe.
pub fun get(map: map<k, v>, key: k, compare: (k, k) -> e order): e maybe<v>
  map.avl-get(key, Nothing, compare)

pub fun get(map: map<k, v>, key: k): ord<k> maybe<v>
  map.get(key, cmp)

// Throws if it is not present.
pub fun get-raw(
  map: map<k, v>,
  key: k,
  compare: (k, k) -> <exn | e> order
): <exn | e> v
  match map.get(key, compare)
    Just(v) -> v
    Nothing -> throw("Key not found in map!")

pub fun get-raw(
  map: map<k, v>,
  key: k
): <exn, ord<k> | e> v
  map.get-raw(key, cmp)

// Removes a key from the map.
pub fun remove(
  map: map<k, v>,
  key: k,
  compare: (k, k) -> <pure | e> order
): <pure | e> map<k, v>
  map.avl-delete(key, compare)

pub fun remove(map: map<k, v>, key: k): <pure, ord<k>> map<k, v>
  map.remove(key, cmp)

// Alters a key / value pair.
// The function to be given should take a maybe<v> and return a maybe<v>
// the input represents if the value is in the map or not, and the output
// determines what it should become (Just(n) replaces the item with n,
// Nothing removes the item from the map).
pub fun alter(
  map: map<k, v>,
  key: k,
  compare: (k, k) -> <pure | e> order,
  alter-fn: maybe<v> -> <pure | e> maybe<v>
): <pure | e> map<k, v>
  match map.get(key, compare).alter-fn
    Just(n) -> map.insert(key, n, compare)
    Nothing -> map.remove(key, compare)

pub fun alter(
  map: map<k, v>,
  key: k,
  alter-fn: maybe<v> -> <pure, ord<k> | e> maybe<v>
): <pure, ord<k> | e> map<k, v>
  alter(map, key, cmp, alter-fn)

fun from-just(m: maybe<a>): pure a
  match m
    Nothing -> throw("This is a nothing!")
    Just(x) -> x

// Gets all the key-value pairs in the map.
pub fun assocs(map: map<k, v>): pure list<(k, v)>
  map.fold(Nil) fn (k, v, acc)
    Cons((k, v.from-just), acc)
