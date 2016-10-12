#lang racket

; In Racket ':' and '->' symbols are used to declare types

;; http://www.pharen.org/reference.html

;; https://docs.racket-lang.org/infix-manual/index.html

(require racket/cmdline)

(define param-error-reporting (make-parameter #f))
(define param-display-errors (make-parameter #f))

(define file-to-compile
  (command-line
   #:multi
   ["--error-reporting" e
                        ""
                        (param-error-reporting e)]
   
   ["--display-errors" d
                       ""
                       (param-display-errors d)]
   
   #:args (filename)
   filename))

(define error-reporting (param-error-reporting))
(define display-errors (param-display-errors))

;; ------------------------------------------------------------------------------------

(define (get-php-exception message code)
  (string-append "throw new Exception(\"" message "\", " (~a code) ");\n") )

(define (get-php-header init-scope)
  (string-append "<?php\n\n"
                 (if error-reporting (string-append "error_reporting(" error-reporting ");\n") "")
                 (if display-errors (string-append "ini_set('display_errors', " display-errors ");\n") "")
                 "if (!getenv('PHAREN_HOME')) {\n"
                 "    " (get-php-exception "PHAREN_HOME is not set" 1)
                 "}\n\n"
                 "require_once(getenv('PHAREN_HOME').'/lang.php');\n"
                 "use Pharen\\Lexical as Lexical;\n"
                 "use \\Seq as Seq;\n"
                 "use \\FastSeq as FastSeq;\n"
                 (string-append "Lexical::$scopes['" init-scope "'] = array();\n\n") ) )

(define (get-bind-lexing scope ident name)
  (string-append "Lexical::bind_lexing(\"" scope "\", " ident ", '$" name "', $" name ");\n") )

(define (vector-from-array lst)
  (string-append "PharenVector::create_from_array(array("
               (string-join (map decorate lst) ", ") "))") )

(define (decorate data)
  (cond
    [(string? data) (string-append "\"" data "\"")]
    [(list? data) (compile data)]
    [(number? data) (~a data)]
    [else (string-append "$" (normal-name data))] ) )

(define (normal-name name)
  (match (~a name)
    ["-" "-"] ; don't replace minus operation
    [_ (string-replace (string-replace (~a name) "-" "_") "~" "fmt_" )] ))

(define (compile-rest line)
  (define args (string-join (map decorate (cdr line)) ", " ))
  (string-append (normal-name (car line)) "(" args ")"  ) )

(define (to-infix line op)
  (string-join (map decorate (cdr line)) op) )

;;
;; Compiles a line to a function call
;;
;; Please keep this 'pure'
;;
(define (compile line)
  (match (car line)
    ['.. (to-infix line " . ")]
    ['+  (to-infix line " + ")]
    ['-  (to-infix line " - ")]
    ['*  (to-infix line " * ")]
    ['$  (string-join (cdr-line))] ;; Infix expression as string
    ['list (vector-from-array (cdr line))]
    [_ (compile-rest line)] ) )

;; Generates a variable definition in the current scope
(define (handle-def line)
  (string-append (string-join (map decorate line) " = ") ";") )

(define (handle-let line)
   (string-append (string-join (map handle-def (car line)) "\n") "\n"
                  (string-join (map compile (cdr line)) ";\n") ";\n"
                  ) )

(define (handle-list line)
  (match (car line)
    ['define-syntax-rule 0] ; just ignore this
    ['fn (displayln "fn")]
    ['let (displayln (handle-let (cdr line)))]    
    ['def (displayln (handle-def (cdr line)))]

    ; Compile the list as a generic language construct
    [_ (displayln (string-append (compile line) ";"))] ) )

(define (read-datum line)
  (define (get-type x)
    (cond
      [(dict? x) "dict"]
      [(list? x) "list"]
      [(pair? x) "pair"]
      [(number? x) "number"]
      [(string? x) "string"] ) )
  
  
  (unless (eof-object? line)
    (cond
      [(list? line) (handle-list line)]
      [(number? line) (displayln "number")]
      [(string? line) (displayln "string")]
      [else (displayln (string-append "*** unknown-type: " (get-type line)))] ) ) )

(define (parse-file filename)
  (define in (open-input-file filename))

  (let ([file-language-info (read-language in)]) null)

  (display (get-php-header "hello"))
  
  ;; Then have to read the rest of the file
  (let loop ()
    (let ([line (read in)])
      (read-datum line)
      (unless (eof-object? line) (loop)))) ) 

(parse-file file-to-compile)
