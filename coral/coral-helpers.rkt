#lang racket

;; (require racket/sandbox)  ;; required for evaluation of racket expressions
(require json)

(provide %list)
(provide $)
(provide list-first)
(provide list-second)
(provide coral:string-join)
(provide /@)
(provide :=)
(provide @*)
(provide expr->code-string)
(provide %apply)
(provide to-string)

;;
;; Decodes a JSON string
;;
(define json-decode string->jsexpr)

(define-namespace-anchor anchor)
(define ns (namespace-anchor->namespace anchor))

;; Identity function (operator)
(define (id x) x)
(define identity id) ;; alias

(define ≤ <=)
(define ≥ >=)
(define (!= . rest) (not (apply = rest)))
(define ≠ !=)

;;
;; Gives the head of expr.
;; If applied on a %list it must always return 'List'
;;
;; https://reference.wolfram.com/language/ref/Head.html
;;
(define %head car)
(define %tail cdr)

;;
;; `%list` is a list of elements
;;
;; https://reference.wolfram.com/language/ref/List.html
;; http://reference.wolfram.com/language/ref/Hold.html
;;
(define (%list . rest)
  (if (> (length rest) 0)
      ;; the first element must be duplicated because
      ;; it is replaced by the apply operation
      (%apply list (append (list (%head rest)) rest))
      '() ))

;;
;; Evaluates an expression by applying (using @@ operator) the Identity function
;; (id operator) over the expression and then calling the Racket code evaluator
;;
;;(define (eval-as-is expr)
;;  (evalu (@@ id expr)))

;;
;; Lazy function definition operator.
;;
;; Used to create creates a composable promise, 
;; where the computation of its body is “attached” to the computation of the following promise,
;; and a single force iterates through the whole chain
;; See: https://docs.racket-lang.org/reference/Delayed_Evaluation.html
;;
;; This can be used only as unary operator
;;
(define (:= f)
  (lazy f))

;;
;; Generates a string of code from a symbolic expression.
;; Symbolic expressions can be converted into a string with this function.
;;
;; Very similar to ToCodeString(), which generates a string of code from a symbolic expression
;; Ref: http://reference.wolfram.com/language/SymbolicC/ref/ToCCodeString.html
;; 
(define ($ text)
  (~a (force text)))

(define to-string ~a)


(define (expr->code-string expr) (coral:string-join (%tail expr)) )


;; https://reference.wolfram.com/language/ref/Composition.html
(define @* compose)

;; using ring operator is also supported
(define ∘ compose)

;; https://reference.wolfram.com/language/ref/Map.html
(define /@ map)

;; using alpha as operator is also supported
(define α map)

;;
;; Replaces the head of `expr` by `f`
;; Apply works with any head, not just List:
;;
;; https://reference.wolfram.com/language/ref/Apply.html
;;
(define (%apply f expr)
  (append (list f) (%tail expr)))

;;
;; Apply Operator (shorthand for %apply)
;; Apply works with any head, not just List:
;;
;; https://reference.wolfram.com/language/ref/Apply.html
;;
(define @@ %apply)


;; https://reference.wolfram.com/language/ref/StringJoin.html
(define (coral:string-join . sl)
  (cond
    [(and (>= (length sl) 2) (string? (list-ref sl 1)) (list? (list-ref sl 0)))
     (string-join (map to-string (list-ref sl 0)) (list-ref sl 1))]

    [(list? (list-ref sl 0)) (string-join (map to-string (list-ref sl 0)))]    
    [else (string-join (map to-string sl))] ))


;;
;; Racket already provides list first, but this function does more than that
;;
(define (list-first pre-post)
  (if (> (length pre-post) 0)
      (%head (eval pre-post))
      ""))

;;
;; Racket already provides list second, but this function does more than that
;;
(define (list-second pre-post)
  (if (> (length pre-post) 2)
      (%head (%tail (eval pre-post)))
      ""))

