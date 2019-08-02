
;; Map[#^2 &, a + b + c] => a^2 + b^2 + c^2

(define a 1)
(define b 2)
(define c 3)

(define (lpow2 x) (list expt x 2))
(define expr (list + 'a 'b 'c))

(define F (car expr))
(define L
  (map lpow2 (cdr expr)) )

(define-namespace-anchor anchor)
(define ns (namespace-anchor->namespace anchor))
(eval (cons F L) ns)
