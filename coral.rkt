#lang racket
;; https://learnxinyminutes.com/docs/racket/

(require json)
(require racket/sandbox)

;; Code evaluation operator
(define $$ (make-evaluator 'racket))

;;
;; Decodes a JSON string
;;
(define json-decode string->jsexpr)

;; Identity function (operator)
(define (id x) x)

;;
;; Gives the head of expr.
;; If applied on a %list it must always return 'List'
;;
;; https://reference.wolfram.com/language/ref/Head.html
;;
(define %head car)
(define %tail cdr)

;; `%list` is a list of elements
;;
;; https://reference.wolfram.com/language/ref/List.html
(define (%list . rest)
  (if (> (length rest) 0)
      ;; the first element must be duplicated because
      ;; it is replaced by the apply operation
      (@@ list (append (list (%head rest)) rest))
      null
   )
  )

(define (eval-as-is expr)
  ($$ (@@ id expr))
  )

;; Lazy function definition operator
;;
;; This can be used only as unary operator
;;
(define/contract (:= f)
  (->i ([f any/c])
       [result promise?])
  (lazy f)
  )

;;
;; String evaluation operator
;;
;; This can be used only as unary operator
;;
(define/contract ($ text)
  (->i ([text any/c])
       [result string?])
  (~a (force text))
  )

;; https://reference.wolfram.com/language/ref/Composition.html
(define @* compose)

;; https://reference.wolfram.com/language/ref/Map.html
(define /@ map)

;;
;; Apply works with any head, not just List:
;;
;; https://reference.wolfram.com/language/ref/Apply.html

(define/contract (%apply f expr)
  (->i ([f procedure?]
        [expr list?])
       [result list?])
  (append (list f) (%tail expr))
  )

;; https://reference.wolfram.com/language/ref/Apply.html
(define @@ %apply)


;; https://reference.wolfram.com/language/ref/StringJoin.html
(define <> string-join)

;; Empty string literal
;;
;; The following expression:
;;     (string-append "a" "b" "c")
;;
;; is equivalent with:
;;     (<% (list "a" "b" "c") %>)
;;
(define <% string-join)
(define %> "")

;; -------------------------------------------------------------------------

(define keyword:return "return")
(define keyword:char "char")

(define prep:include "#include")

(define (list-first pre-post)
  (if (> (length pre-post) 0)
      (%head ($$ pre-post))
      "")
  )

(define (list-second pre-post)
  (if (> (length pre-post) 2)
      (%head (%tail ($$ pre-post)))
      "")
  )

;;
;; It is a symbolic representation of a comment.
;; Includes text to add before and after the comment.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CComment.html
;;
(define (c-comment text pre-post)
  (%list (<%
       (list ($ (list-first pre-post))
             "/*" ($ text) "*/"
             ($ (list-second pre-post))
             )
       %>))
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CParentheses.html
(define (c-parentheses symb)
  (%list (<> (list "(" ($ symb) ")" )))
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CAssign.html
(define (c-assign lhs rhs)
  (%list (<> (list lhs " = " ($ rhs))))
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/COperator.html
(define (c-operator oper lst)
  (%list (<> (/@ $ lst) (<> (list " " oper " "))))
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CConditional.html
(define (c-conditional test true-arg false-arg)
  (:= (<> (list ($ test) " ? " ($ true-arg) " : " ($ false-arg))))
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CBlock.html
(define/contract (c-block args)
  (->i ([args list?])
       [result promise?])
  (:= (<>
       (list "{" "\n"
             (<> (/@ (@* $ c-statement)
                     args
                     ) "\n")
             "\n" "}" "\n"
             )
       ))
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CDeclare.html
(define/contract (c-declare type var)
  (->i ([type any/c]
        [var string?])
       [result promise?])
  (:= (<% (list ($ type) " " var) %>))
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CReturn.html
(define (c-return arg)
  (:= (<% (list keyword:return " " ($ arg)) %>))
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CInclude.html
(define (c-include header)
  (:= (<% (list prep:include " " "\"" header "\"\n") %>))
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CFunction.html
(define/contract (c-function type name args body)
  (->i ([type any/c]
        [name string?]
        [args list?]
        [body any/c])
       [result promise?])
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

;; https://reference.wolfram.com/language/SymbolicC/ref/CStatement.html
(define (c-statement obj)
  (:= (<% (list ($ obj) ";") %>))
  )

;;
;; `c-constant` is a symbolic representation of a constant.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CConstant.html
;;
(define (c-constant value type)
  (:= (<% (list ($ value) type) %>))
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CPointerType.html
(define (c-pointer-type type)
  (:= (<% (list ($ type) "*") %>))
  )
