
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

#### Examples in C++ code

To understand why this is so powerful and useful at the same time, let's see an example on how the same functionality can be achieved in C++. (Ignored memory management handling, that will add extra complexity in the code).

First we have to consider an `Expression` class, that allows working with lists, converting different types and joining strings. For a simple example we just used `vector` instead of `list`.

##### Expression Class

```cpp
class Expression {
  const char* value;
protected:
  vector<Expression*> List;
  void append(const char* val) {
    List.push_back(new Expression(val));
  }
  
  void append(Expression* expr) {
    List.push_back(expr);
  }

public:
  explicit Expression() {
    value = "";
  }
  
  Expression(const char* value) {
    this->value = value;
  }

  string toString() {
    string s;
  
    int n = List.size();
    if (0 == n) {
      return string(this->value);
    }

    for (int i = 0; i < n; ++i) {
        if (List[i] != NULL) {
           s += List[i]->toString();
        }
     }
    return s;
  }
};
```


##### CReturn Class

```cpp
class CReturn : public Expression {
  Expression* mArg;

  // Implementation of (c-return arg)
  void c_return() { append("return"); append(" "); append(mArg); }
public:
  CReturn(Expression* arg) : mArg(arg) { c_return(); }

  // The effect of (list eval (~a arg)) 
  CReturn(const char* arg) { mArg = new Expression(arg); c_return(); }
};
```

```racket
(define (c-return arg)
  (list string-append "return" " " (list eval (~a arg)) ))

```

##### CStatement Class

```cpp
class CStatement : public Expression {
  Expression* mObj;

public:
  // Implementation of (c-statement obj)
  CStatement(Expression* obj) : mObj(obj) { append(mObj); append(";"); }
};
```
