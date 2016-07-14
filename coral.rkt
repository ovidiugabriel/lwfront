#lang racket

;; https://learnxinyminutes.com/docs/racket/

(require json)
(require racket/sandbox)  ;; required for evaluation of racket expressions

;;
;; Decodes a JSON string
;;
(define json-decode string->jsexpr)

;; Code evaluation operator
(define $$ (make-evaluator 'racket))

;; Identity function (operator)
(define (id x) x)
(define Identity id) ;; alias

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
;;
(define (%list . rest)
  (if (> (length rest) 0)
      ;; the first element must be duplicated because
      ;; it is replaced by the apply operation
      (@@ list (append (list (%head rest)) rest))
      null
   )
  )

;;
;; Evaluates an expression by applying (using @@ operator) the Identity function
;; (id operator) over the expression and then calling the Racket code evaluator
;;
(define (eval-as-is expr)
  ($$ (@@ id expr))
  )

;;
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
;; Very similar to ToCodeString(), which generates a string of code from a symbolic expression
;; 
;; Symbolic expressions are inert; they evaluate to themselves, staying in 
;; an unevaluated form.
;; Symbolic expressions can be converted into a string with this function.
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
;;
(define/contract (%apply f expr)
  (->i ([f procedure?]
        [expr list?])
       [result list?])
  (append (list f) (%tail expr))
  )

;;
;; Apply Operator (shorthand for %apply)
;; Apply works with any head, not just List:
;;
;; https://reference.wolfram.com/language/ref/Apply.html
;;
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
;; Makes it easy to working with a hierarchical view of code as Raket expressions.
;; This supports the use of the Racket language for the creation, manipulation, 
;; and optimization of code. 
;;
;; https://reference.wolfram.com/language/SymbolicC/guide/SymbolicC.html
;;
;; -------------------------------------------------------------------------

;; a list of simple definitions
(define keyword:return "return")
(define keyword:char "char")

(define prep:include "#include")

;; 
;; Functions
;;

;;
;; Racket already provides list first, but this function does more than that
;;
(define (list-first pre-post)
  (if (> (length pre-post) 0)
      (%head ($$ pre-post))
      "")
  )

;;
;; Racket already provides list second, but this function does more than that
;;
(define (list-second pre-post)
  (if (> (length pre-post) 2)
      (%head (%tail ($$ pre-post)))
      "")
  )

;;
;; Functions for C code generation
;;
;; https://reference.wolfram.com/language/SymbolicC/guide/SymbolicC.html
;;

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


;; https://reference.wolfram.com/language/SymbolicC/ref/CStandardMathOperator.html
(define (c-standard-math-operator)
  )
  
;; https://reference.wolfram.com/language/SymbolicC/ref/CExpression.html
(define (c-expression)
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CProgram.html
(define (c-program)
  )
  
;; https://reference.wolfram.com/language/SymbolicC/ref/CDo.html
(define (c-do)
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CFor.html
(define (c-for)
  )
  
;; https://reference.wolfram.com/language/SymbolicC/ref/CIf.html
(define (c-if)
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CSwitch.html
(define (c-switch)
  )
  
;; https://reference.wolfram.com/language/SymbolicC/ref/CDefault.html
(define (c-default)
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CWhile.html
(define (c-while)
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CCast.html
(define (c-cast)
  )
  
;; https://reference.wolfram.com/language/SymbolicC/ref/CDeclare.html
(define (c-declare)
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CEnum.html
(define (c-enum)
  )
  
;; https://reference.wolfram.com/language/SymbolicC/ref/CStruct.html
(define (c-struct)
  )
  
;; https://reference.wolfram.com/language/SymbolicC/ref/CUnion.html
(define (c-union)
  )
  
;; https://reference.wolfram.com/language/SymbolicC/ref/CTypedef.html
(define (c-typedef)
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CSizeOf.html
(define (c-size-of)
  )

;;
;;a symbolic representation of a call to a function.  
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CCall.html
;;
(define (c-call fname args)
  )

;;
;; a symbolic representation of a break statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CBreak.html
;;
(define (c-break))

;;
;; a symbolic representation of a continue statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CContinue.html
;;
(define (c-continue) ;; fun take no params.
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CGoto.html
(define (c-goto)
  )
  
;; https://reference.wolfram.com/language/SymbolicC/ref/CLabel.html
(define (c-label)
  )

;;
;; a symbolic representation of access from a struct.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CMember.html
;;
(define (c-member obj mem)
  )
  
;; https://reference.wolfram.com/language/SymbolicC/ref/CPointerMember.html
(define (c-pointer-member)
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CAddress.html
(define (c-address)
  )
  
;; https://reference.wolfram.com/language/SymbolicC/ref/CDereference.html
(define (c-dereference)
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CArray.html
(define (c-array)
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CDefine.html
(define (c-define)
  )

;;
;; a symbolic representation of a preprocessor error directive.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CError.html
(define (c-error line)
  )

;; https://reference.wolfram.com/language/SymbolicC/ref/CLine.html
(define (c-line line)
  )
