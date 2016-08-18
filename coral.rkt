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
;; Replaces the head of `expr` by `f`
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
;; ---------------------------------------------------------------------
;; Symbol                     Description
;; ---------------------------------------------------------------------
;; << C expressions. >>
;; (c-operator)  	            an operator expression
;; (c-assign)                 represent an assignment
;; (c-standard-math-operator) call a standard math operator
;; (c-conditional)            a conditional expression
;;
;; << Grouping constructs to hold entire statements. >>
;; (c-statement)              a C statement
;; (c-block)	                a block of C statements
;; (c-program)	              an entire program
;;
;; << Programming constructs. >>
;; (c-for)	                  a for loop
;; (c-if) 	                  an if statement
;; (c-do) 	                  a do while statement
;; (c-while)	                a while statement
;; (c-switch) 	              a switch statement
;; (c-default)	              a switch statement
;;
;; << Type constructs. >>
;; (c-struct)                 a struct definition
;; (c-union)	                a union definition
;; (c-typedef)	              a typedef statement
;; (c-enum) 	                an enum definition
;; (c-cast) 	                a cast statement
;; (c-pointer-type)	          a pointer type
;; (c-size-of)	              a sizeof expression
;; (c-declare)	              declare the type of an object
;;
;; << Function constructs. >>
;; (c-function)	              a function definition
;; (c-call)	                  a function call
;; (c-return)	                a return statement
;;
;; << Execution flow control constructs. >>
;; (c-goto)	                  a goto statement
;; (c-label)	                a label
;; (c-continue)	              a continue statement
;; (c-break)	                a break statement
;;
;; << Struct access constructs. >>
;; (c-member)	                access a member of a struct
;; (c-pointer-member)	        access a member of a pointer to a struct
;;
;; << Address and dereference operators. >>
;; (c-address)	              take the address of an object
;; (c-dereference)	          dereference a pointer
;; (c-array)	                an array
;;
;; << Formatting constructs. >>
;; (c-comment)	              a comment
;; (c-parentheses)	          parentheses
;; (c-string)	                a string
;;                            - convert symbolic C to a string
;;
;; << Preprocessor statements. >>
;; (c-include)	              include a header
;; (c-define)	                define a macro
;; (c-error)	                generate an error
;; (c-line)	                  set the line number
;; (c-pragma)	                extra information for the compiler
;; (c-preprocessor-if)        conditional compile if
;; (c-preprocessor-ifdef)     conditional compile ifdef
;; (c-preprocessor-ifndef)	  conditional compile ifndef
;; (c-preprocessor-else)	    conditional compile else
;; (c-preprocessor-elif)	    conditional compile elif
;; (c-preprocessor-endif)	    conditional compile endif
;; (c-undef)	                undefine a macro
;; ---------------------------------------------------------------------

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

;;
;; is a symbolic representation of an assignment statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CAssign.html
;;
(define (c-assign lhs rhs)
  (%list (<> (list lhs " = " ($ rhs))))
  )

;;
;; a symbolic representation of an operator.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/COperator.html
;;
(define (c-operator oper lst)
  (%list (<> (/@ $ lst) (<> (list " " oper " "))))
  )

;;
;; a symbolic representation of an inline conditional expression.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CConditional.html
;;
(define (c-conditional test true-arg false-arg)
  (:= (<> (list ($ test) " ? " ($ true-arg) " : " ($ false-arg))))
  )

;; 
;;  @param list args
;;
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

;;
;; a symbolic representation of a variable declaration.
;;
;; This function is using a contract
;;    @param any type
;;    @param string var
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CDeclare.html
(define/contract (c-declare type var)
  (->i ([type any/c]
        [var string?])
       [result promise?])
  (:= (<% (list ($ type) " " var) %>))
  )

;;
;; is a symbolic representation of a return from a function. 
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CReturn.html
;;
(define (c-return arg)
  (:= (<% (list keyword:return " " ($ arg)) %>))
  )

;;
;; a symbolic representation of a preprocessor include statement. 
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CInclude.html
;;
(define (c-include header)
  (:= (<% (list prep:include " " "\"" header "\"\n") %>))
  )

;;
;; a symbolic representation of a function definition.
;;
;; This function is using a contract.
;;    @param any type
;;    @param string name
;;    @param list args
;;    @param any body
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CFunction.html
;;
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

;;
;; is a symbolic representation of a statement. 
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CStatement.html
;;
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

;;
;; a symbolic representation of a type that is a pointer to a type.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPointerType.html
;;
(define (c-pointer-type type)
  (:= (<% (list ($ type) "*") %>))
  )

;;
;; a symbolic representation of a standard math operator.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CStandardMathOperator.html
;;
(define (c-standard-math-operator oper args)
  )

;;
;; a symbolic representation of code that will format using CForm[arg].
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CExpression.html
;;
(define (c-expression arg)
  )

;;
;; a symbolic representation of an entire program.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CProgram.html
;;
(define (c-program args)
  )

;;
;; is a symbolic representation of a do/while statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CDo.html
;;
(define (c-do body test)
  )

;;
;; a symbolic representation of a for loop.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CFor.html
;;
(define (c-for init test incr body)
  )

;;
;; a symbolic representation of a conditional statement. 
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CIf.html
;;
(define (c-if test on-true on-false)
  )

;;
;; is a symbolic representation of a switch statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CSwitch.html
;;
(define (c-switch xcond statements)
  )

;;
;; a symbolic representation of a default statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CDefault.html
;;
(define (c-default) ;; fun takes no param
  )

;;
;; a symbolic representation of a while statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CWhile.html
;;
(define (c-while test body)
  )

;;
;; a symbolic representation of a cast of obj to type.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CCast.html
;;
(define (c-cast type obj)
  )

;;
;; a symbolic representation of a variable declaration.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CDeclare.html
;;
(define (c-declare type var)
  )

;;
;; a symbolic representation of an enum statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CEnum.html
;;
(define (c-enum name members)
  )

;;
;; a symbolic representation of a struct.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CStruct.html
;;
(define (c-struct name members)
  )

;;
;; a symbolic representation of a union.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CUnion.html
;;
(define (c-union name members)
  )
  
;;
;; a symbolic representation of a type declaration.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CTypedef.html
;;
(define (c-typedef type var)
  )

;;
;; a symbolic representation of a sizeof expression.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CSizeOf.html
;;
(define (c-size-of obj)
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
(define (c-break) ;; fun take no params
  )

;;
;; a symbolic representation of a continue statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CContinue.html
;;
(define (c-continue) ;; fun take no params.
  )

;;
;; a symbolic representation of a goto statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CGoto.html
;;
(define (c-goto label)
  )
  
;;
;; a symbolic representation of a label.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CLabel.html
;;
(define (c-label label)
  )

;;
;; a symbolic representation of access from a struct.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CMember.html
;;
(define (c-member obj mem)
  )

;;
;; a symbolic representation of access from a pointer to a struct.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPointerMember.html
;;
(define (c-pointer-member obj mem)
  )

;;
;; a symbolic representation of the address of an object.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CAddress.html
;;
(define (c-address obj)
  )

;;
;; a symbolic representation of the dereferencing of a pointer.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CDereference.html
;;
(define (c-dereference obj)
  )

;;
;; a symbolic representation of an array.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CArray.html
;;
(define (c-array name args)
  )

;;
;; a symbolic representation of a preprocessor define.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CDefine.html
;;
(define (c-define def)
  )

;;
;; a symbolic representation of a preprocessor error directive.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CError.html
(define (c-error text-line)
  )

;;
;; a symbolic representation of a preprocessor line directive.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CLine.html
;;
(define (c-line line)
  )

;;
;; a symbolic representation of a preprocessor pragma directive.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPragma.html
;;
(define (c-pragma line)
  )

;;
;; a symbolic representation of a preprocessor elif conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorElif.html
;;
(define (c-preprocessor-elif bcond)
  )
  
;;
;; a symbolic representation of a preprocessor else conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorElse.html
;;
(define (c-preprocessor-else) ;; fun take no params.
  )

;;
;; a symbolic representation of a preprocessor endif conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorEndif.html
(define (c-preprocessor-endif)  ;; fun take no params.
  )

;;
;; a symbolic representation of a preprocessor if conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorIf.html
;;
(define (c-preprocessor-if bcond on-true on-false)
  )

;;
;; a symbolic representation of a preprocessor ifdef conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorIfdef.html
;;
(define (c-preprocessor-ifdef bcond on-true on-false)
  )

;;
;; a symbolic representation of a preprocessor ifndef conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorIfndef.html
;;
(define (c-preprocessor-ifndef bcond on-true on-false)
  )
  
;;
;; a symbolic representation of a preprocessor undef.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CUndef.html
;;
(define (undef def)
  )
