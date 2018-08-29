#lang racket

(provide with)

(require (for-syntax racket/syntax))

(define-syntax (with stx)
  (syntax-case stx ()
    ; base case
    [(with () body ...)
     #'(begin body ...)]

    ; variables and arguments
    [(with ([(vars ...) (proc args ...)] others ...) body ...)
     (%with-impl "call-with-" stx)]

    ; variables without arguments
    [(with ([(vars ...) proc] others ...) body ...)
     (%with-impl "call-with-"
       #'(with ([(vars ...) (proc)] others ...) body ...))]

    ; one variable
    [(with ([var proc-maybe-args] others ...) body ...)
     (%with-impl "call-with-"
       #'(with ([(var) proc-maybe-args] others ...) body ...))]

    ; arguments without variables
    [(with ((proc args ...) others ...) body ...)
     (%with-impl "with-"
       #'(with ([() (proc args ...)] others ...) body ...))]

    ; neither arguments nor variables
    [(with (proc others ...) body ...)
     (%with-impl "with-"
       #'(with ([() (proc)] others ...) body ...))]))

(define-for-syntax (%with-impl prefix stx)
  (syntax-case stx ()
    [(%with-impl ([(vars ...) (proc args ...)] others ...) body ...)
     (with-syntax ([name (with-prefix prefix #'proc)])
       #'(name args ...
           (lambda (vars ...)
             (with (others ...) body ...))))]))

(define-for-syntax (with-prefix prefix symbol-stx)
  (format-id symbol-stx "~a~a" prefix (syntax-e symbol-stx)))
