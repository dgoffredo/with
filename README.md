with
====
Convenient syntax to combine `with-` and `call-with-` invocations.

Why
---
Like Python, Racket has a convention for context management, or scoping
side-effects. In Racket, context managers take a `lambda`. You might write:
```racket
(call-with-atomic-output-file file-path
  (lambda (out temp-file)
    (call-with-input-file file-path
      (lambda (in)
        (with-module-reading-parameterization
          (lambda ()
            "Transform code from in to out ...")))))) 
```
That code will:
- create a temporary file at `temp-file`,
- open an output port to it called `out`,
- open `file-path` for reading with an input part called `in`,
- set up the reader such that it can read module syntax,
- execute the user code in this context (the innermost `lambda`)
- reset the reader to its previous state,
- close `file-path` for reading,
- close `temp-file` for writing,
- move `temp-file` to replace `file-path`.

It would be nice to be able to flatten out that code, and ditch the lambdas.
Thus, the `with` macro is born:
```racket
(with ([(out temp-file) (atomic-output-file file-path)]
       [in (input-file file-path)]
       module-reading-parameterization)
  "Transform code from in to out ...")
```
It's the `let` of context managers.

Note how you drop the "with-" or "call-with-" prefix.

What
----
[with.rkt](with.rkt) is a Racket module that provides a macro, `with`, that
simplifies the usage of nested context-creating procedures; in particular,
those whose name begins with "with-" or "call-with-".

How
---
```racket
#lang racket

(require "with.rkt")


(with ([(out temp-file) (atomic-output-file file-path)]
       [in (input-file file-path)]
       module-reading-parameterization)
  "Transform code from in to out ...")
```