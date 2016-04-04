#lang racket
; https://learnxinyminutes.com/docs/racket/

(require json)
; (require javascript/ast)
(require racket/sandbox)

; Code evaluation operator
(define $$ (make-evaluator 'racket))

;
; Decodes a JSON string
;
(define json-decode string->jsexpr)

; Identity function (operator)
(define (id x)
  x
  )

;
; Gives the head of expr.
; If applied on a %list it must always return 'List'
;
; https://reference.wolfram.com/language/ref/Head.html
;
(define %head car)
(define %tail cdr)

; `%%list` is a list of elements
;
; https://reference.wolfram.com/language/ref/List.html
(define (%%list . rest)
  (%%apply list rest)
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
; Apply works with any head, not just List:
;
; https://reference.wolfram.com/language/ref/Apply.html

(define (%%apply f expr)
  (append (list f) (%tail expr))
  )

; https://reference.wolfram.com/language/ref/Apply.html
(define @@ %%apply)


; https://reference.wolfram.com/language/ref/StringJoin.html
(define <> string-join)

; Empty string literal
;
; The following expression:
;     (string-append "a" "b" "c")
;
; is equivalent with:
;     (<% (list "a" "b" "c") %>)
;
(define <% string-join)
(define %> "")

; -------------------------------------------------------------------------

(define keyword:return "return")
(define keyword:char "char")

(define prep:include "#include")

;
; It is a symbolic representation of a comment.
; Includes text to add before and after the comment.
;
; https://reference.wolfram.com/language/SymbolicC/ref/CComment.html
;
(define (c-comment text pre-post)
  (:= (<%
       (list ($ (%head pre-post))
             "/*" ($ text) "*/"
             ($ (%head (%tail pre-post)))
             )
       %>))
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
  (:= (<% (list ($ type) " " var) %>))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CReturn.html
(define (c-return arg)
  (:= (<% (list keyword:return " " ($ arg)) %>))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CInclude.html
(define (c-include header)
  (:= (<% (list prep:include " " "\"" header "\"\n") %>))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CFunction.html
(define (c-function type name args body)
  (:= (<%
       (list (<> (/@ $ type) " ") " " name
             ; parameters list
             "(" (<> (/@ $ args) ", ") ")"
             ($ body)
             )
       %>
       )
      )
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CStatement.html
(define (c-statement obj)
  (:= (<% (list ($ obj) ";") %>))
  )

;
; `c-constant` is a symbolic representation of a constant.
;
; https://reference.wolfram.com/language/SymbolicC/ref/CConstant.html
;
(define (c-constant value type)
  (:= (<% (list ($ value) type) %>))
  )

; https://reference.wolfram.com/language/SymbolicC/ref/CPointerType.html
(define (c-pointer-type type)
  (:= (<% (list ($ type) "*") %>))
  )
