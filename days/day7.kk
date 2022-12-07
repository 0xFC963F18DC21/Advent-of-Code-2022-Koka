module day7

import std/text/parse

import utils/input
import utils/ord
import utils/qsort

type fstree
  Dir(name: string, contents: list<fstree>)
  File(name: string, filesize: int)

fun size(tree: fstree): pure int
  match tree
    Dir(_, contents)  -> contents.foldl(0) fn (acc, f) { acc + f.size }
    File(_, filesize) -> filesize

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

fun bfst(terms: list<term>, acc: fstree): io (fstree, list<term>)
  match terms
    Nil -> (acc, Nil)
    Cons(t, ts) ->
      match t
        Cd(mvt)           -> match mvt
          Just(x) -> match acc
            Dir(_, _) -> match ts.bfst(Dir(x, []))
              (dir, ts_) -> ts_.bfst(acc.add-child(dir))
            _         -> throw("How are you cd-ing into a file?")
          Nothing -> (acc, ts)
        Ls                -> ts.bfst(acc)
        DirT(_)           -> ts.bfst(acc)
        FileT(size, name) -> ts.bfst(acc.add-child(File(name, size)))

fun build-fstree(terms: list<term>): io fstree
  terms.tail.bfst(Dir("/", [])).fst

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
      .build-fstree()
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
      val fs = get-terminal().build-fstree()

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
