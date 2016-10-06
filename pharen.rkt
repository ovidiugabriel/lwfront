#lang racket

; In Racket ':' and '->' symbols are used to declare types

;; http://www.pharen.org/reference.html

(define (print-header init-scope)
  (displayln "<?php")
  (displayln "require_once(getenv('PHAREN_HOME').'/lang.php');")
  (displayln "use Pharen\\Lexical as Lexical;")
  (displayln "use \\Seq as Seq;")
  (displayln "use \\FastSeq as FastSeq")
  (displayln (string-append "Lexical::$scopes['" init-scope "'] = array();")) #|<ins>|# )

(define (get-type x)
  (cond
    [(dict? x) "dict"]
    [(list? x) "list"]
    [(pair? x) "pair"]
    [(number? x) "number"]
    [(string? x) "string"] #|<ins>|# ) )

(define (decorate data)
  (match (get-type data)
    ["string" (string-append "\"" data "\"")]
    ["list" (compile data)]
    ["number" (~a data)]
    [_ (string-append "$" (normal-name data))] #|<ins>|# ) )

(define (normal-name name)
  (match (~a name)
    ["-" "-"] ; don't replace minus operation
    [_ (string-replace (~a name) "-" "_") ] #|<ins>|# ))

(define (compile-rest line)
  (define args (string-join (map decorate (cdr line)) ", " ))
  (string-append (normal-name (car line)) "(" args ")" ) #|<ins>|# )

(define (to-infix line op)
  (string-join (map decorate (cdr line)) op)
  )

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
    [_ (compile-rest line)] #|<ins>|# ) )

(define (handle-list line)
  (match (car line)
    ['define-syntax-rule (displayln "rule")]
    ['define (displayln "define")]
    ['fn (displayln "fn")]
    ['let (displayln "let")]
    [_ (displayln (string-append (compile line) ";"))] #|<ins>|# ) )

(define (read-datum line)
  (unless (eof-object? line)
    (cond
      [(list? line) (handle-list line)]
      [(number? line) (displayln "number")]
      [(string? line) (displayln "string")]
      [else (displayln (string-append "*** unknown-type: " (get-type line)))] #|<ins>|# ) ) )

(define (parse-file filename)
  (define in (open-input-file filename))
  
  ;; First line is language-info
  ;; we need to mute that
  (define file-language-info (read-language in))
  
  (print-header "hello")
  
  ;; Then have to read the rest of the file
  (let loop ()
    (define line (read in))
    (read-datum line)
    (unless (eof-object? line) (loop))) #|<ins>|# )

(parse-file "new-hello.rkt")
