
https://docs.racket-lang.org/guide/Pairs__Lists__and_Racket_Syntax.html

##### Features

* lazy evaluation (delayed assignment)
  * holding list form until explicit evaluation - native support from the language syntax
  * creating composable promise
  * thunking with a lambda function

###### Holding List Constructor

`%list` holds a list of elements in its original list form, preventing function application until this is explicitly requested using `$$` operator

```
> (define lst (%list 1 2 3 4))
> lst ; this is the list in hold form
'(#<procedure:list> 1 2 3 4)

> ($$ lst) ; this will evaluate to a list
'(1 2 3 4)
```

###### Simple quote operator equivalence

There is an obvious equivalence between `%list` and `'` operator. 
And their effect is the same - to prevent the applicative behavior in list expressions. This is done by duplicating the head of the list.

```
> (define x '(+ 1 2)) ; 1 + 2 in holding form
> x
'(+ 1 2)

> ($$ x) ; lazy evaluate value of x
3

> (list + 1 2)         ; delayed additive expression
'(#<procedure:+> 1 2)

> ($$ (list + 1 2))
3

> (list list 1 2 3 4)       ; it is the same as (%list 1 2 3 4)
'(#<procedure:list> 1 2 3 4)

```

At this level [list expressions](https://github.com/LispTO/LLTHW/blob/master/book/1-01-03-expressions.md) 
are the same as in LISP.
When a list is evaluated, it is treated as code unless it is quoted. 


```
> '(a b c)
'(a b c)
> (list 'a 'b 'c)
'(a b c)
> (list a b c)
a: undefined;
 cannot reference undefined identifier
  context...:
   /opt/racket/share/racket/collects/racket/private/misc.rkt:87:7

```


###### Delayed Assignment using promises

A promise encapsulates an expression to be evaluated on demand.

```
> (define d (lazy '(1 2 3 4)))
> d ; a promise that encapsulates the expression
#<promise:...:44:2>

> (force d) ; evaluates the promise
'(1 2 3 4)

> (~a (force d)) ; this always evaluates to a string
"(1 2 3 4)"

> (define (yy) (lazy 5))
> (force yy) ; here yy is a function
#<procedure:yy>

> (force (yy))
5

> (define y (lazy 5))
> (force y) ; here y is a variable
5

```

###### Lambda function (Racket)

```
> (define (x) (lambda () 5))
> x ; here x is a function
#<procedure:x>

> (x) ; the lambda function is returned
#<procedure:lambda>

> ((x)) ; the lambda function is called
5
```

###### cons keyword

```
> (cons "a" "b")
'("a" . "b")
> (cons 1 '(2 3))
'(1 2 3)
```

###### 'quote' on the playground

```
> (%apply + '(1 2))
'(#<procedure:+> 2)
> (eval (%apply + '(1 2)))
2
> (quote (+ 1 2))
'(+ 1 2)
> (%apply * (quote (+ 1 2)))
'(#<procedure:*> 1 2)
> (eval (%apply * (quote (+ 1 2))))
```

##### Lectures

* http://www.paulgraham.com/progbot.html



