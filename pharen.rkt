#lang racket

; In Racket ':' and '->' symbols are used to declare types

;; http://www.pharen.org/reference.html

(define (get-php-header init-scope)
  (string-append "<?php\n\n"
                 "require_once(getenv('PHAREN_HOME').'/lang.php');\n"
                 "use Pharen\\Lexical as Lexical;\n"
                 "use \\Seq as Seq;\n"
                 "use \\FastSeq as FastSeq\n"
                 (string-append "Lexical::$scopes['" init-scope "'] = array();\n\n") ) )

(define (get-type x)
  (cond
    [(dict? x) "dict"]
    [(list? x) "list"]
    [(pair? x) "pair"]
    [(number? x) "number"]
    [(string? x) "string"] ) )

(define (decorate data)
  (cond
    [(string? data) (string-append "\"" data "\"")]
    [(list? data) (compile data)]
    [(number? data) (~a data)]
    [else (string-append "$" (normal-name data))] ) )

(define (normal-name name)
  (match (~a name)
    ["-" "-"] ; don't replace minus operation
    [_ (string-replace (~a name) "-" "_") ] ))

(define (compile-rest line)
  (define args (string-join (map decorate (cdr line)) ", " ))
  (string-append (normal-name (car line)) "(" args ")" ) )

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
    [_ (compile-rest line)] ) )

(define (handle-list line)
  (match (car line)
    ['define-syntax-rule (displayln "rule")]
    ['define (displayln "define")]
    ['fn (displayln "fn")]
    ['let (displayln "let")]
    [_ (displayln (string-append (compile line) ";"))] ) )

(define (read-datum line)
  (unless (eof-object? line)
    (cond
      [(list? line) (handle-list line)]
      [(number? line) (displayln "number")]
      [(string? line) (displayln "string")]
      [else (displayln (string-append "*** unknown-type: " (get-type line)))] ) ) )

(define (parse-file filename)
  (define in (open-input-file filename))
  
  ;; First line is language-info
  ;; we need to mute that
  (define file-language-info (read-language in))
  
  (display (get-php-header "hello"))
  
  ;; Then have to read the rest of the file
  (let loop ()
    (define line (read in))
    (read-datum line)
    (unless (eof-object? line) (loop))) )

(parse-file "new-hello.rkt")
