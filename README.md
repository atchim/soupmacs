# Soup Macros

> A collection of useful macros for [Fennel].

## Macros

### `call [head ...]`

Shorthand for accessing and calling a function.

`head` is the base to access the function. Non-last arguments of `...` are
treated as additional accesses needed to call the function. If `...` has no
argument, the macro expands to a function call of `head` with no arguments.

The last argument in `...` is the argument to be passed to the function call.
If it is a sequence with zero or more than one items, its content is unpacked
as the arguments to the function.

#### Examples

```fennel
(import-macros {: call} :soupmacs)
(assert (= :number (call type 0)))
(assert (= :table (call type [0])))
(assert (= 3 (call math :max [2 3 -1 0])))
(assert (= :foo (call table :concat [:foo])))
(assert (= :foo.bar (call table :concat [[:foo :bar] :.])))
(let [foo {:bar {:baz #:baz}} bar :bar]
  ;(assert (= :baz (call foo bar :baz))) ; This does not work.
  (assert (= :baz (call foo bar :baz []))))
```

### `modcall [mod ...]`

Shorthand for both accessing and calling a function of `mod`.

`mod` is the name of the module. Non-last arguments in `...` are treated as
table field accesses needed to call the function. If `...` has no argument,
the macro expands to a function call, without arguments, of the object
returned by `mod`.

The last argument in `...` always stands for the argument to be passed to the
function call. If it is a sequence with zero or more than one items, its
content is unpacked as the arguments to the function.

#### Examples

```fennel
(import-macros {: modcall} :soupmacs)
(local {: like?} (require :examples.utils))

(assert (like? (modcall :examples.foo) []))
(assert (like? (modcall :examples.foo :bar) [:bar]))
(assert (like? (modcall :examples.foo [:bar]) [[:bar]]))
(assert (like? (modcall :examples.foo [:bar :baz]) [:bar :baz]))
(assert (like? (modcall :examples.foo :bar []) []))
(assert (like? (modcall :examples.foo :bar :baz) [:baz]))
```

### `modget [mod ...]`

Shorthand for getting an item in `mod`.

#### Examples

```fennel
(import-macros {: modget} :soupmacs)
(assert (= :table (type (modget :examples.foo))))
(assert (= :table (type (modget :examples.foo :bar))))
(assert (= :table (type (modget :examples.foo :bar :baz))))
```

### `nonnil [...]`

Shorthand for filtering non-nil values of `...` to a new table.

#### Examples

```fennel
(import-macros {: nonnil} :soupmacs)
(fn sum [t] (accumulate [sum 0 _ n (ipairs t)] (+ sum n)))
(assert (= 8 (sum (nonnil -1 1 nil 3 5))))
```

### `oneof? [x ...]`

Shorthand for returning if `x` is equal to some value in `...`.

#### Examples

```fennel
(import-macros {: oneof?} :soupmacs)
(let [age 25 country :Hawaii name :McLOVIN]
  (assert (oneof? 25 age country name))
  (assert (not (oneof? :McINLOV age country name)))
  (assert (not (oneof? :Kawaii age country name))))
```

#### Caveats

Avoid passing table literals as arguments, since it is likely that they will
not match. Also, passing a table literal as argument for the `x` parameter
results in the table literal being evaluated `n` times, where `n` is the
number of arguments of `...`.

### `ordef [val def]`

Shorthand for returning non-nil `val` or a `def` one.

#### Examples

```fennel
(import-macros {: ordef} :soupmacs)
(let [?t nil t {}] (assert (= t (ordef ?t t))))
(assert (= (ordef false true) false))
(assert (= (ordef 0 1) 0))
(assert (= (ordef "" :foo) ""))
```

### `ty= [x ...]`

Shorthand for returning whether `x` has one of given `...` types.

#### Examples

```fennel
(import-macros {: ty=} :soupmacs)
(assert (ty= 0 :number))
(assert (ty= [] :nil :table))
(assert (not (ty= 0 :boolean :string :table)))
```

[Fennel]: https://fennel-lang.org