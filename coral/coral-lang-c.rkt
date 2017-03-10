#lang racket

(require "coral-helpers.rkt")


;; a list of simple definitions
(define keyword:return "return")
(define keyword:char "char")

(define prep:include "#include")

;;
;; Functions for C code generation
;;
;; https://reference.wolfram.com/language/SymbolicC/guide/SymbolicC.html
;;
;; ---------------------------------------------------------------------
;; Symbol                          Description
;; ---------------------------------------------------------------------
;; << C expressions. >>
(provide c-operator)               ;; an operator expression
(provide c-assign)                 ;; represent an assignment
(provide c-standard-math-operator) ;; call a standard math operator
(provide c-conditional)            ;;  a conditional expression

;; << Grouping constructs to hold entire statements. >>
(provide c-statement)              ;;  a C statement
(provide c-block)                  ;; a block of C statements
(provide c-program)                ;; an entire program

;; << Programming constructs. >>
(provide c-for)                    ;; a for loop
(provide c-if)                     ;; an if statement
(provide c-do)                     ;; a do while statement
(provide c-while)                  ;; a while statement

(provide c-switch)                 ;; a switch statement
(provide c-default)                ;; a switch statement

;; << Type constructs. >>
(provide c-struct)                 ;; a struct definition
(provide c-union)                  ;; a union definition
(provide c-typedef)                ;; a typedef statement
(provide c-enum)                   ;; an enum definition
(provide c-cast)                   ;; a cast statement
(provide c-pointer-type)           ;; a pointer type
(provide c-size-of)                ;; a sizeof expression
(provide c-declare)                ;; declare the type of an object

;; << Function constructs. >>
(provide c-function)               ;; a function definition 
(provide c-call)                   ;; a function call
(provide c-return)                 ;; a return statement


;; << Execution flow control constructs. >>
(provide c-goto)                   ;; a goto statement 
(provide c-label)                  ;; a label
(provide c-continue)               ;; a continue statement
(provide c-break)                  ;; a break statement

;; << Struct access constructs. >>
(provide c-member)                 ;; access a member of a struct
(provide c-pointer-member)         ;; access a member of a pointer to a struct

;; << Address and dereference operators. >>
(provide c-address) ;; take the address of an object
(provide c-dereference) ;; dereference a pointer
(provide c-array) ;; an array

;; << Formatting constructs. >>
(provide c-comment) ;; a comment
(provide c-parentheses) ;; parentheses
(provide c-string) ;; a string

;; << Preprocessor statements. >>
(provide c-include) ;; include a header
(provide c-define) ;; define a macro
(provide c-error) ;; generate an error
(provide c-line) ;; set the line number
(provide c-pragma) ;; extra information for the compiler
(provide c-preprocessor-if) ;; conditional compile if
(provide c-preprocessor-ifdef) ;; conditional compile ifdef
(provide c-preprocessor-ifndef) ;; conditional compile ifndef
(provide c-preprocessor-else) ;; conditional compile else
(provide c-preprocessor-elif) ;; conditional compile elif
(provide c-preprocessor-endif) ;; conditional compile endif
(provide c-undef) ;; undefine a macro

;; Extra goodies
(provide c-main)

;; ---------------------------------------------------------------------


;;
;; It is a symbolic representation of a comment.
;; Includes text to add before and after the comment.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CComment.html
;;
(define (c-comment text pre-post)
  (%list (string-append ($ (list-first pre-post))
             "/*" ($ text) "*/"
             ($ (list-second pre-post))
             )
         )
  )
  

;; https://reference.wolfram.com/language/SymbolicC/ref/CParentheses.html
(define (c-parentheses symb)
  (%list (coral:string-join (list "(" ($ symb) ")" ))))

;;
;; is a symbolic representation of an assignment statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CAssign.html
;;
(define (c-assign lhs rhs)
  (%list (coral:string-join (list lhs " = " ($ rhs)))))

;;
;; a symbolic representation of an operator.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/COperator.html
;;
(define (c-operator oper lst)
  (%list (coral:string-join (/@ $ lst) (coral:string-join (list " " oper " ")))))

;;
;; a symbolic representation of an inline conditional expression.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CConditional.html
;;
(define (c-conditional test true-arg false-arg)
  (:= (coral:string-join (list ($ test) " ? " ($ true-arg) " : " ($ false-arg)))))

;; 
;;  @param list args
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CBlock.html
;;
;; Automatically calls `c-statement` (when needed?)
;;
(define (c-block args)
  (:= (coral:string-join
       (list "{" "\n"
             (coral:string-join (/@ (@* $ c-statement)
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
(define (c-declare type var)
  (:= (string-append ($ type) " " var)))

;;
;; is a symbolic representation of a return from a function. 
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CReturn.html
;;
(define (c-return arg)
  (:= (string-append keyword:return " " ($ arg)) ))

;;
;; a symbolic representation of a preprocessor include statement. 
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CInclude.html
;;
(define (c-include header)
  (:= (string-append prep:include " " "\"" header "\"\n") ))

;;
;; a symbolic representation of a function definition.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CFunction.html
;;
;; type - a list of strings
;; name - a string
;; args - a list
;; body - a string
;;
(define (c-function type name args body)
  (:= (string-append (coral:string-join type) " " name
          ; parameters list
          "(" (coral:string-join (map coral:string-join args) ", ") ")"
          ($ body)
          )))



;;
;; is a symbolic representation of a statement. 
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CStatement.html
;;
(define (c-statement obj)
  (:= (string-append ($ obj) ";") ))

;;
;; `c-constant` is a symbolic representation of a constant.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CConstant.html
;;
(define (c-constant value type)
  (:= (string-append ($ value) type)))

;;
;; a symbolic representation of a type that is a pointer to a type.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPointerType.html
;;
(define (c-pointer-type type)
  (:= (string-append ($ type) "*") ))
  

;;
;; a symbolic representation of a standard math operator.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CStandardMathOperator.html
;;
(define (c-standard-math-operator oper args)
  (:= (string-join args (string-append " " oper " ")) ))

;;
;; a symbolic representation of code that will format using CForm[arg].
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CExpression.html
;;
(define (c-expression arg) 0)
;; used in conjunction with c-form which converts an S-expression to C code
(define (c-form expr) 0)


;;
;; a symbolic representation of an entire program.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CProgram.html
;;
(define (c-program args) 0)

;;
;; is a symbolic representation of a do/while statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CDo.html
;;
(define (c-do body test)
  (:= (string-append "do {\n" body "\n} while (" test ");\n")))

;;
;; a symbolic representation of a for loop.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CFor.html
;;
(define (c-for init test incr body) 0)

;;
;; a symbolic representation of a conditional statement. 
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CIf.html
;;
(define (c-if test on-true on-false) 0)

;;
;; is a symbolic representation of a switch statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CSwitch.html
;;
(define (c-switch xcond statements) 0)

;;
;; a symbolic representation of a default statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CDefault.html
;;
;; function takes no parameters
;;
(define (c-default) 0)

;;
;; a symbolic representation of a while statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CWhile.html
;;
(define (c-while test body) 0)

;;
;; a symbolic representation of a cast of obj to type.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CCast.html
;;
(define (c-cast type obj) 0)

;;
;; a symbolic representation of an enum statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CEnum.html
;;
(define (c-enum name members) 0)

;;
;; a symbolic representation of a struct.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CStruct.html
;;
(define (c-struct name members) 0)

;;
;; a symbolic representation of a union.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CUnion.html
;;
(define (c-union name members) 0)
  
;;
;; a symbolic representation of a type declaration.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CTypedef.html
;;
(define (c-typedef type var) 0)

;;
;; a symbolic representation of a sizeof expression.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CSizeOf.html
;;
(define (c-size-of obj) 0)

;;
;;a symbolic representation of a call to a function.  
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CCall.html
;;
(define (c-call fname args)
  (:= (string-append fname "(" (string-join args ", ") ")" )))

;;
;; a symbolic representation of a break statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CBreak.html
;;
;; fun take no params
;;
(define (c-break) 0)

;;
;; a symbolic representation of a continue statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CContinue.html
;;
;; fun take no params.
;;
(define (c-continue) 0)

;;
;; a symbolic representation of a goto statement.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CGoto.html
;;
(define (c-goto label) 0)

;;
;; a symbolic representation of a label.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CLabel.html
;;
(define (c-label label) 0)

;;
;; a symbolic representation of access from a struct.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CMember.html
;;
(define (c-member obj mem) 0)

;;
;; a symbolic representation of access from a pointer to a struct.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPointerMember.html
;;
(define (c-pointer-member obj mem) 0)

;;
;; a symbolic representation of the address of an object.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CAddress.html
;;
(define (c-address obj) 0)

;;
;; a symbolic representation of the dereferencing of a pointer.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CDereference.html
;;
(define (c-dereference obj) 0)

;;
;; a symbolic representation of an array.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CArray.html
;;
(define (c-array name args) 0)

;;
;; a symbolic representation of a preprocessor define.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CDefine.html
;;
(define (c-define def) 0)

;;
;; a symbolic representation of a preprocessor error directive.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CError.html
(define (c-error text-line) 0)

;;
;; a symbolic representation of a preprocessor line directive.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CLine.html
;;
(define (c-line line) 0)

;;
;; a symbolic representation of a preprocessor pragma directive.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPragma.html
;;
(define (c-pragma line) 0)

;;
;; a symbolic representation of a preprocessor elif conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorElif.html
;;
(define (c-preprocessor-elif bcond) 0)
  
;;
;; a symbolic representation of a preprocessor else conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorElse.html
;;
;; function take no parameters.
;;
(define (c-preprocessor-else)  0)

;;
;; a symbolic representation of a preprocessor endif conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorEndif.html
;;
;; function take no parameters.
;;
(define (c-preprocessor-endif) 0)

;;
;; a symbolic representation of a preprocessor if conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorIf.html
;;
(define (c-preprocessor-if bcond on-true on-false) 0)

;;
;; a symbolic representation of a preprocessor ifdef conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorIfdef.html
;;
(define (c-preprocessor-ifdef bcond on-true on-false) 0)

;;
;; a symbolic representation of a preprocessor ifndef conditional.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CPreprocessorIfndef.html
;;
(define (c-preprocessor-ifndef bcond on-true on-false) 0)
  
;;
;; a symbolic representation of a preprocessor undef.
;;
;; https://reference.wolfram.com/language/SymbolicC/ref/CUndef.html
;;
(define (c-undef name) 0)

(define (c-string string)
  (list string-append "\"" string "\""))

(define (c-main block)
  (c-function '("int") "main" '(("int" "argc") ("char*" "argv[]")) block))
