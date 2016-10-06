#lang racket

; In Racket ':' and '->' symbols are used to declare types

;; http://www.pharen.org/reference.html

(define (print-header init-scope)
  (displayln "<?php")
  (displayln "require_once(getenv('PHAREN_HOME').'/lang.php');")
  (displayln "use Pharen\\Lexical as Lexical;")
  (displayln "use \\Seq as Seq;")
  (displayln "use \\FastSeq as FastSeq")
  (displayln (string-append "Lexical::$scopes['" init-scope "'] = array();"))
  )

(define (get-type x)
  (cond
    ((dict? x) "dict")
    ((list? x) "list")          
    ((pair? x) "pair")
    ((number? x) "number")
    ((string? x) "string")
    )
  )

(define (decorate data)
  (match (get-type data)
    ["string" (string-append "\"" data "\"")]
    ["list" (compile data)]
    [_ (string-append "$" (normal-name data))]
      )
  )

(define (normal-name name)
  (string-replace (~a name) "-" "_")
  )

;;
;; Compiles a line to a function call
;;
;; Please keep this 'pure'
;;
(define (compile line)
  (define args (string-join (map decorate (cdr line)) ", " ) )
  (string-append (normal-name (car line)) "(" args ")")
  )

(define (handle-list line)
  (match (car line)
    ['define-syntax-rule (displayln "rule")]
    ['define (displayln "define")]
    ['fn (displayln "fn")]
    ['print (displayln "print")]
    ['echo (displayln "echo")]
    ['let (displayln "let")]
    ['.. (displayln "..")]
    [_ (displayln (string-append (compile line) ";"))]
    )
  )

(define (read-datum line)
  (unless (eof-object? line)
    (cond
      [(list? line) (handle-list line)]
      [(number? line) (displayln "number")]
      [(string? line) (displayln "string")]
      [else (displayln (string-append "*** unknown-type: " (get-type line)))]
      )
    ;; (println (car line))
    )
  )

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
    (unless (eof-object? line) (loop)))
  )

(parse-file "new-hello.rkt")

