#lang racket

;; Map[#^2 &, a + b + c] => a^2 + b^2 + c^2

(define a 1)
(define b 2)
(define c 3)

(define (%map func expr)
  (let ([head (car expr)])    
    (cons head (map func (cdr expr))) ))

(define L (%map (λ (x) (list expt x 2)) (list + 'a 'b 'c)))

(define-namespace-anchor anchor)
(define ns (namespace-anchor->namespace anchor))
(eval L ns)
