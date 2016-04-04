#lang racket

; Identity function (operator)
(define (id x)
  x
  )

; Lazy function definition operator
;
; This can be used only as unary operator
;
(define (:= f)
  (lazy f)
  )

;
; String evaluation operator
;
; This can be used only as unary operator
;
(define ($ text)
  (~a (force text))
  )

; https://reference.wolfram.com/language/ref/Composition.html
(define @* compose)

; https://reference.wolfram.com/language/ref/Map.html
(define /@ map)

;
; https://reference.wolfram.com/language/ref/Apply.html
;
; Example: (@@ + '(1 2 3))
; Result: 6
;
(define @@ apply)

; https://reference.wolfram.com/language/ref/StringJoin.html
(define <> string-join)
