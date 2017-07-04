
### Lazy expressions

Lazy expressions can be easily stored in lists as `(list ...)`. Argument evaluation must be also delayed using `(list eval arg)`

#### Lazy expressions in Racket code

```racket
#lang racket

(define (c-return arg)
  (list string-append "return" " " (list eval (~a arg)) ))

(define (c-statement obj)
  (list string-append (list eval obj) ";") )

(current-namespace (make-base-namespace))

(c-return 0)
;; '(#<procedure:string-append> "return" " " (#<procedure:eval> "0"))

(eval (c-return 0))
;; "return 0"

(c-statement (c-return 0))
;; '(#<procedure:string-append> (#<procedure:eval> (#<procedure:string-append> "return" " " 
;;   (#<procedure:eval> "0"))) ";")

(eval (c-statement (c-return 0)))
;; "return 0;"
```

#### Examples in Java code

To understand why this is so powerful and useful at the same time, let's see an example on how the same functionality can be achieved in Java. 

First we have to consider an `Expression` class, that allows working with lists, converting different types and joining strings. For a simple example we just used `vector` instead of `list`.

##### Expression Class

```java
import java.util.Vector;

class Expression {
    private String value;
    private Vector<Expression> vector;

    public Expression() {
        this("");
    }
    
    public Expression(int value) {
        this(String.valueOf(value));
    }

    public Expression(String value) {
        this.vector = new Vector<Expression>();
        this.value = value;
    }
    
    public void append(String value) {
        this.append(new Expression(value));
    }
    
    public void append(Expression value) {
        this.vector.add(value);
    }
    
    public void append(int value) {
        this.append(String.valueOf(value));
    }
    
    public String toString() {
        if (this.vector.size() == 0) {
            return this.value;
        }
        StringBuffer buffer = new StringBuffer();
        for (Expression expr : this.vector) {
            buffer.append(expr); 
        }
        return buffer.toString();
    }
}
```

##### CReturn Class

```java
class CReturn extends Expression {
    private Expression arg;

    public CReturn(int value) {
        this(new Expression(value));
    }
    
    public CReturn(String value) {
        this(new Expression(value));
    }
    
    public CReturn(Expression expr) {
        this.arg = expr;
        this.CReturnImpl();
    }
    
    private void CReturnImpl() {
        this.append("return");
        this.append(" ");
        this.append(this.arg);
    }
}
```

```racket
(define (c-return arg)
  (list string-append "return" " " (list eval (~a arg)) ))

```

##### CStatement Class

```java
class CStatement extends Expression {
    private Expression expr;
    public CStatement(Expression expr) {
        this.expr = expr;
        this.append(expr);
        this.append(";");
    }
}
```

```racket
(define (c-statement obj)
  (list string-append (list eval obj) ";") )
```
