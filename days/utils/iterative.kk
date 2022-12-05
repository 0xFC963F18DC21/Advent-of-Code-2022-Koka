module iterative

/*
 * ITERATIVE LOOPING
 *
 * The two effects defined in this file are designed to replicate the usage of
 * the for and while loops common in procedural languages like C, C++, Java, etc.
 *
 * There are two styles of loop being offered:
 *
 * 1. UNLABELLED LOOPS (loop / ifor / iwhile / continue / break)
 *
 * These loops are unlabelled, so control flow statements like continue and break
 * act upon the innermost loop construct. In order to handle these properly, use
 * `loop` as your top-level handler.
 *
 *   fun some-loops() {
 *     with loop
 *
 *     var x := 0
 *     ifor { x := 0 } { x < 10 } { x := x + 1 } {
 *       if   x < 2
 *       then continue()
 *
 *       iwhile { x < 5 } {
 *         println(x)
 *         x := x + 1
 *       }
 *     }
 *   }
 *
 * 2. LABELLED LOOPS (label-loop / label-for / label-while / label-continue / label-break)
 *
 * These loops are labelled, so you can label your loops with strings in order to
 * choose which one to continue / break from. However, due to limitations of the
 * implementation, continuing and breaking is an O(n) operation depending on the
 * number of layers of labelled looping you have.
 *
 * As it is usually good code style and practice to minimise the layers of loop
 * one's code enters at any point, that usually is not much of a performance issue.
 *
 * As with unlabelled loops, you need a top-level handler. In this case, it is
 * `label-loop`. Use it similarly to the top-level handler for unlabelled loops.
 *
 *  fun more-loops() {
 *     with label-loop
 *
 *     var x := 0
 *     label-for("outer") { x := 0 } { x < 10 } { x := x + 1 } {
 *       if   x < 2
 *       then label-continue("outer")
 *
 *       label-while("inner") { x > 5 } {
 *         x := x + 1
 *         println(x)
 *         label-break("outer")
 *       }
 *     }
 *   }
 *
 * When using both pre-defined top-level handlers, it is possible to arbitrarily
 * nest both kinds of loops into each other, and their control flow functions act
 * exactly how you'd expect it to.
 *
 *  pub fun test-both-loops() {
 *    with loop
 *    with label-loop
 *  
 *    var x := True
 *    var y := 0
 *  
 *    label-while("outer") { x } {
 *      iwhile { True } {
 *        label-for("inner") { y := 0 } { y < 10 } { y := y + 1 } {
 *          if   y == 1
 *          then
 *            println("CTN")
 *            label-continue("inner")
 *
 *          println(y)
 *  
 *          if   y == 6
 *          then
 *            x := False
 *            println("SET FALSE")
 *            break()
 *        }
 *      }
 *    }
 *  }
 */

// Effectful iterative looping.
effect iterative
  ctl break(): ()

  ctl continue(): ()

fun while-internal(
  cond: () -> <pure, iterative | e> bool,
  action: () -> <pure, iterative | e> ()
): <pure, iterative | e> ()
  if cond() then
    action()
    while-internal(cond, action)

fun for-internal(
  cond: () -> <pure, iterative | e> bool,
  post: () -> <pure, iterative | e> (),
  action: () -> <pure, iterative | e> ()
): <pure, iterative | e> ()
  if cond() then
    action()
    post()
    for-internal(cond, post, action)

// An iterative-style while-loop.
// WARNING: Although the condition action has the "iterative" effect, do not call
//          break or continue in it, as it may cause some oddities to occur.
pub fun iwhile(
  cond: () -> <pure, iterative | e> bool,
  action: () -> <pure, iterative | e> ()
): <pure, iterative | e> ()
  with override
    ctl break() ()
    ctl continue() iwhile(cond, action)

  while-internal(cond, action)

// An iterative-style for-loop.
// WARNING: Although the pre, condition and post actions have the "iterative" effect,
//          do not call break or continue in it, as it may cause some oddities to occur.
pub fun ifor(
  pre: () -> <pure, iterative | e> (),
  cond: () -> <pure, iterative | e> bool,
  post: () -> <pure, iterative | e> (),
  action: () -> <pure, iterative | e> ()
): <pure, iterative | e> ()
  with override
    ctl break() ()
    ctl continue() ifor(post, cond, post, action)
    // No, the above is not a typo.
    // A continue invocation should invoke the post-action before the condition runs
    // All languages with a for construct like this (C, C++, Java, etc...) do that.

  pre()
  for-internal(cond, post, action)

// Declare a top-level body that deals with loops.
pub fun loop(body: () -> <pure, iterative | e> ()): <pure | e> ()
  with handler
    ctl break()
      throw("Do not do a top-level break!")
    ctl continue()
      throw("Do not do a top-level continue!")

  body()

// Labelled effectful iterative looping.
effect label-iterative
  ctl label-break(to-label: string): ()

  ctl label-continue(to-label: string): ()

fun label-while-internal(
  cond: () -> <pure, label-iterative | e> bool,
  action: () -> <pure, label-iterative | e> ()
): <pure, label-iterative | e> ()
  if cond() then
    action()
    label-while-internal(cond, action)

fun label-for-internal(
  cond: () -> <pure, label-iterative | e> bool,
  post: () -> <pure, label-iterative | e> (),
  action: () -> <pure, label-iterative | e> ()
): <pure, label-iterative | e> ()
  if cond() then
    action()
    post()
    label-for-internal(cond, post, action)

// An iterative-style while-loop with labels.
// WARNING: Although the condition action has the "label-iterative" effect, do not call
//          label-break or label-continue in it, as it may cause some oddities to occur.
fun label-while(
  label: string,
  cond: () -> <pure, label-iterative | e> bool,
  action: () -> <pure, label-iterative | e> ()
): <pure, label-iterative | e> ()
  with override
    ctl label-break(to-label)
      if   label == to-label
      then ()
      else label-break(to-label)
    ctl label-continue(to-label)
      if   label == to-label
      then label-while(label, cond, action)
      else label-continue(to-label)

  if   label == ""
  then throw("Label cannot be empty!")

  label-while-internal(cond, action)

// An iterative-style for-loop with labels.
// WARNING: Although the pre, condition and post actions have the "label-iterative" effect,
//          do not call label-break or label-continue in it, as it may cause some oddities to occur.
fun label-for(
  label: string,
  pre: () -> <pure, label-iterative | e> (),
  cond: () -> <pure, label-iterative | e> bool,
  post: () -> <pure, label-iterative | e> (),
  action: () -> <pure, label-iterative | e> ()
): <pure, label-iterative | e> ()
  with override
    ctl label-break(to-label)
      if   label == to-label
      then ()
      else label-break(to-label)
    ctl label-continue(to-label)
      if   label == to-label
      then label-for(label, post, cond, post, action)
      else label-continue(to-label)
      // See the note in ifor.

  if   label == ""
  then throw("Label cannot be empty!")

  pre()
  label-for-internal(cond, post, action)

// Declare a top-level body that deals with labelled loops.
pub fun label-loop(body: () -> <pure, label-iterative | e> ()): <pure | e> ()
  with handler
    ctl label-break(to-label)
      throw("Invalid label: " ++ to-label)
    ctl label-continue(to-label)
      throw("Invalid label: " ++ to-label)

  body()
