##### Features

* lazy evaluation (delayed assignment)
  * creating composable promise
  * holding list form until explicit evaluation
  * thunking with a lambda function

###### Delayed Assignment Operator

A promise encapsulates an expression to be evaluated on demand.

```
```

###### Holding List Constructor

`%list` holds a list of elements in its original list form, preventing function application until this is explicitly requested using `$$` operator

```
(define lst (%list e1 e2 ...))
```
