module day7

import std/text/parse

import utils/input
import utils/ord
import utils/ordlist

type fstree
  Dir(name: string, contents: list<fstree>)
  File(name: string, filesize: int)

fun size(tree: fstree): pure int
  match tree
    Dir(_, contents)  -> contents.foldl(0) fn (acc, f) { acc + f.size }
    File(_, filesize) -> filesize

type fszipper
  Done
  DirZ(z: fszipper, name: string, contents: list<fstree>)

fun fs-up(zip: fszipper, t: fstree): pure (fszipper, fstree)
  match zip
    Done          -> (Done, t)
    DirZ(z, n, c) -> (z, Dir(n, Cons(t, c)))

fun fs-top(zip: fszipper, t: fstree): pure fstree
  match zip
    Done          -> t
    DirZ(z, n, c) -> z.fs-top(Dir(n, Cons(t, c)))

fun fs-down(zip: fszipper, t: fstree, name: string): pure (fszipper, fstree)
  match t
    Dir(n, c) -> (DirZ(zip, n, c), Dir(name, []))
    _         -> throw("Can't go into a File as if it was a Dir.")

type term
  Cd(mvt: maybe<string>)
  Ls
  DirT(name: string)
  FileT(size: int, name: string)

fun parse-term(): parse term
  fun pcd()
    char('$')
    whitespace()
    pstring("cd")
    whitespace()

    val rch = many
      satisfy-fail("pcd: ???", next)

    match rch.string
      ".." -> Cd(Nothing)
      dir  -> Cd(Just(dir))

  fun pls()
    char('$')
    whitespace()
    pstring("ls")

    Ls

  fun pdirt()
    pstring("dir ")

    val rch = many
      satisfy-fail("pdirt: ???", next)

    DirT(rch.string)

  fun pfilet()
    val sz = pint()
    whitespace()
    val rch = many
      satisfy-fail("pfilet: ???", next)

    FileT(sz, rch.string)

  [pcd, pls, pdirt, pfilet].choose

pub fun get-terminal(): io list<term>
  with x <- get-input-lines(7).map
  x.slice.parse(parse-term).maybe.default(Ls)

fun add-child(par: fstree, c: fstree): pure fstree
  match par
    Dir(n, cn) -> Dir(n, Cons(c, cn))
    _          -> throw("You can't make a file a parent!")

fun bfstz(terms: list<term>, cd: fstree, zip: fszipper): pure (fstree, list<term>)
  match terms
    Nil         -> (zip.fs-top(cd), Nil)
    Cons(t, ts) ->
      match t
        Cd(mvt)           -> match mvt
          Just(x) -> match zip.fs-down(cd, x)
            (z_, cd_) -> ts.bfstz(cd_, z_)
          Nothing -> match zip.fs-up(cd)
            (z_, cd_) -> ts.bfstz(cd_, z_)
        Ls                -> ts.bfstz(cd, zip)
        DirT(_)           -> ts.bfstz(cd, zip)
        FileT(size, name) -> ts.bfstz(cd.add-child(File(name, size)), zip)

fun build-fstree-zipper(terms: list<term>): pure fstree
  terms.tail.bfstz(Dir("/", []), Done).fst

fun fs-find-matching(t: fstree, pred: fstree -> e bool): e list<fstree>
  val pref = if t.pred then [t] else []
  match t
    Dir(_, cs) -> pref ++ cs.foldr([]) fn (t_, acc)
      t_.fs-find-matching(pred) ++ acc
    File(_, _) -> pref

fun dir-cmp(
  t: fstree,
  compare: (int, int) -> <pure, ord<int> | e> order,
  mx: int
): <pure, ord<int> | e> maybe<order>
  match t
    Dir(_, _)  -> Just(t.size.compare(mx))
    File(_, _) -> Nothing

pub fun day7(part: int): io ()
  with ord-int
  match part
    1 -> get-terminal()
      .build-fstree-zipper()
      .fs-find-matching(fn (t) {
        val c = dir-cmp(t, cmp, 100000).default(Gt)
        c.is-lt || c.is-eq
      })
      .map(size)
      .sum
      .println
    2 ->
      // Prelims.
      val total-space = 70000000
      val min-unused = 30000000
      val fs = get-terminal().build-fstree-zipper()

      // Calculations.
      val current-unused = total-space - fs.size
      val need-to-free = min-unused - current-unused
      val matching = fs.fs-find-matching(fn (t) {
        val c = dir-cmp(t, cmp, need-to-free).default(Lt)
        c.is-eq || c.is-gt
      })

      with fun cmp(l: fstree, r: fstree) l.size.cmp(r.size)
      matching.minimum-by.size.show.println
    _ -> "Invalid part!".println
