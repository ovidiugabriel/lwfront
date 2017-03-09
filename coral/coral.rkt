#lang racket

;; https://learnxinyminutes.com/docs/racket/

(require "coral-helpers.rkt")
(require "coral-lang-c.rkt")


;; -------------------------------------------------------------------------
;; Makes it easy to working with a hierarchical view of code as Raket expressions.
;; This supports the use of the Racket language for the creation, manipulation, 
;; and optimization of code. 
;;
;; https://reference.wolfram.com/language/SymbolicC/guide/SymbolicC.html
;;
;; -------------------------------------------------------------------------

;; 
;; Functions
;;


;;
;; compiles a string of C code and creates an executable file.
;;
(define (create-executable code name) 
  (expr->code-string code))

;;
;; compiles a string of C code and creates a library file.
;;
(define (create-library code name) 
  (expr->code-string code))

;;
;; compiles a string of C code and creates an object file.
;;
(define (create-object-file source name)
  (expr->code-string source))
