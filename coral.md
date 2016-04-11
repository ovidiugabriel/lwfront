##### Features

* lazy evaluation (delayed assignment)
  * creating composable promise
  * holding list form until explicit evaluation
  * thunking with a lambda function

###### Delayed Assignment Operator

A promise encapsulates an expression to be evaluated on demand.

```
> (define d (:= '(1 2 3 4)))
> d ; a promise that encapsulates the expression
#<promise:...:44:2>

> (force d) ; evaluates the promise
'(1 2 3 4)

> ($ d) ; this always evaluates to a string
"(1 2 3 4)"

> (define (yy) (:= 5))
> ($ yy) ; here yy is a function
"#<procedure:yy>"

> ($ (yy))
"5"

> (define y (:= 5))
> ($ y) ; here y is a variable
"5"

```

###### Holding List Constructor

`%list` holds a list of elements in its original list form, preventing function application until this is explicitly requested using `$$` operator

```
> (define lst (%list 1 2 3 4))
> lst ; this is the list in hold form
'(#<procedure:list> 1 2 3 4)

> ($$ lst) ; this will evaluate to a list
'(1 2 3 4)
```

###### Simple quote operator (Racket)

```
> (define x '(+ 1 2)) ; 1 + 2 in holding form
> x
'(+ 1 2)

> ($$ x) ; lazy evaluate value of x
3
```

###### Lambda function (Racket)

> (define (x) (λ () 5))
> x ; here x is a function
#<procedure:x>

> (x) ; the lambda function is returned
#<procedure:λ>

> ((x)) ; the lambda function is called
5
