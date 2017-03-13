
Lazy expressions can be easily stored in lists as `(list ...)`. Argument evaluation must be also delayed using `(list eval arg)`

```racket
#lang racket

(define (c-return arg)
  (list string-append "return" " " (list eval (~a arg)) ))

(define (c-statement obj)
  (list string-append (list eval obj) ";") )

(current-namespace (make-base-namespace))

(c-return 0)
;; '(#<procedure:string-append> "return" " " (#<procedure:eval> "0"))
(eval (c-return 0))
;; "return 0"
(c-statement (c-return 0))
'(#<procedure:string-append> (#<procedure:eval> (#<procedure:string-append> "return" " " 
   (#<procedure:eval> "0"))) ";")
(eval (c-statement (c-return 0)))
;; "return 0;"
```
