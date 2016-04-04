#lang racket
; https://learnxinyminutes.com/docs/racket/

(require json)
(require javascript/ast)
(require racket/sandbox)

; Code evaluation operator
(define $$ (make-evaluator 'racket))

(define json-decode string->jsexpr)

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

; -------------------------------------------------------------------------

;
; It is a symbolic representation of a comment.
; Includes text to add before and after the comment.
;
; https://reference.wolfram.com/language/SymbolicC/ref/CComment.html
;
(define (c-comment text pre-post)
  (:= (<>
       (list ($ (car pre-post))
             "/*" ($ text) "*/"
             ($ (car (cdr pre-post)))
             )
       ))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CParentheses.html
(define (c-parentheses symb)
  (:= (<> (list "(" ($ symb) ")" )))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CAssign.html
(define (c-assign lhs rhs)
  (:= (<> (list lhs " = " ($ rhs))))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/COperator.html
(define (c-operator oper lst)
  (:= (<> (/@ $ lst) (<> (list " " oper " "))))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CConditional.html
(define (c-conditional test true-arg false-arg)
  (:= (<> (list ($ test) " ? " ($ true-arg) " : " ($ false-arg))))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CBlock.html
(define (c-block args)
  (:= (<>
       (list "{" "\n"
             (<> (/@ (@* $ c-statement)
                     args
                     ) "\n")
             "\n" "}" "\n"
             )
       ))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CDeclare.html
(define (c-declare type var)
  (:= (<> (list type " " var)))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CReturn.html
(define (c-return arg)
  (:= (<> (list "return" " " ($ arg))))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CInclude.html
(define (c-include header)
  (:= (<> (list "#include \"" header "\"")))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CFunction.html
(define (c-function type name args body)
  (:= (<>
       (list (<> (/@ $ type) " ") " " name
             ; parameters list
             "(" (<> (/@ $ args) ", ") ")"
             ($ body)
             )
       )
      )
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CStatement.html
(define (c-statement obj)
  (:= (<> (list ($ obj) ";")))
  )
