module iterative

// Effectful iterative looping.
effect iterative
  ctl break(): ()

  ctl continue(): ()

fun while-internal(
  cond: () -> <div, iterative | e> bool,
  action: () -> <div, iterative | e> ()
): <div, iterative | e> ()
  if cond() then
    action()
    while-internal(cond, action)

fun for-internal(
  cond: () -> <div, iterative | e> bool,
  post: () -> <div, iterative | e> (),
  action: () -> <div, iterative | e> ()
): <div, iterative | e> ()
  if cond() then
    action()
    post()
    for-internal(cond, post, action)

// An iterative-style while-loop.
// WARNING: Although the condition action has the "iterative" effect, do not call
//          break or continue in it, as it may cause some oddities to occur.
pub fun iwhile(
  cond: () -> <div, iterative | e> bool,
  action: () -> <div, iterative | e> ()
): <div, iterative | e> ()
  with override
    ctl break() ()
    ctl continue()
      while-internal(cond, action)

  while-internal(cond, action)

// An iterative-style for-loop.
// WARNING: Although the pre, condition and post actions have the "iterative" effect,
//          do not call break or continue in it, as it may cause some oddities to occur.
pub fun ifor(
  pre: () -> <div, iterative | e> (),
  cond: () -> <div, iterative | e> bool,
  post: () -> <div, iterative | e> (),
  action: () -> <div, iterative | e> ()
): <div, iterative | e> ()
  with override
    ctl break() ()
    ctl continue()
      post()
      for-internal(cond, post, action)
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
      then label-while-internal(cond, action)
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
      then label-for-internal(cond, post, action)
      else label-continue(to-label)

  if   label == ""
  then throw("Label cannot be empty!")

  label-for-internal(cond, post, action)

// Declare a top-level body that deals with labelled loops.
pub fun label-loop(body: () -> <pure, label-iterative | e> ()): <pure | e> ()
  with handler
    ctl label-break(to-label)
      throw("Invalid label: " ++ to-label)
    ctl label-continue(to-label)
      throw("Invalid label: " ++ to-label)

  body()

pub fun test-label-while() {
  with loop
  with label-loop

  var x := True
  var y := 0

  label-while("outer") { x } {
    iwhile { True } {
      label-for("inner") { y := 0 } { y < 10 } { y := y + 1 } {
        println(y)

        if   y == 6
        then
          x := False
          println("SET FALSE")
          break()
      }
    }
  }
}
