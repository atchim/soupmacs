# Soup Macros

> A collection of useful macros for [Fennel].

## Usage

Pass the `--add-macro-path` argument with the path to the `soupmacs.fnl` file
to the `fennel` command to be able to import and use the macros. The following
snippets exemplify that.

```bash
fennel --add-macro-path $PATH_TO_SOUPMACS_FNL -c foo.fnl >foo.lua
```

```fennel
; Contents of file "foo.fnl".
(import-macros {: modcall} :soupmacs)
(modcall :bar :baz (:quux :corge))
```

## Macros

### `modcall [mod ...]`

Expands to a function call into `mod`.

`mod` must be a string naming the module. The last argument in `...` always
stands for the argument to be passed to the function call. If it is a list,
its content is unpacked as the arguments to the function. For instance, using
`(modcall :foo (:bar :baz))` expands to `((require :foo) :bar :baz)`. If
`...` has no argument, the macro expands to a function call, without
arguments, of the object returned by `mod`.

Non-last arguments in `...` are treated as the accesses needed to call the
function. For example, using `(modcall :foo :bar :baz)` expands to
`((. (require :foo) :bar) :baz)`.

#### Examples

```fennel
(modcall :foo) ; Expands to `((require :foo))`.
(modcall :foo :bar) ; Expands to `((require :foo) :bar)`.
(modcall :foo (:bar)) ; Expands to the same as the last one.
(modcall :foo :bar ()) ; Expands to `((. (require :foo) :bar))`.
(modcall :foo :bar :baz) ; Expands to `((. (require :foo) :bar) :baz)`.
(modcall :foo (:bar :baz)) ; Expands to `((require :foo) :bar :baz)`.
```

### `modget? [mod ...]`

Expands to access of `mod` and, optionally its `...` nested items.

#### Examples

```fennel
(modget? :foo) ; Expands to `(require :foo)`.
(modget? :foo :bar) ; Expands to `(?. (require :foo) :bar)`.
(modget? :foo :bar :baz) ; Expands to `(?. (require :foo) :bar :baz)`.
```

### `nonnil [t]`

Expands to a filtering of non-nil values from `t` to a new table.

#### Note

If `t` has negative-indexed values, the returned table is not guaranteed to
be sorted.

#### Examples

```fennel
(let
  [ t (nonnil {-1 -1 1 1 2 nil 3 3 5 5})
    sum (accumulate [sum 0 _ n (ipairs t)] (+ sum n))]
  (assert (= sum 8)))
```

### `oneof? [x ...]`

Expands to an `or` form, like `(or (= x y) (= x z) ...)`.

#### Examples

```fennel
(oneof? x y) ; Expands to `(= x y)`.
(oneof? x y z) ; Expands to `(or (= x y) (= x z))`.
(oneof? x y z a) ; Expands to `(or (= x y) (= x z) (= x a))`.
```

### `ordef [val def]`

Expands to an `if` expression that returns a non-nil `val` or its `def`.

#### Examples

```fennel
(let [t {}] (assert (= (ordef nil t) t)))
(assert (= (ordef false true) false))
(assert (= (ordef 0 1) 0))
(assert (= (ordef "" :foo) ""))
```

### `subcalls [func mod ...]`

Expands to function calls of `func` for each `...` submodules of `mod`.

#### Examples

```fennel
(subcalls :foo :bar :baz) ; Expands to `(. (require :foo.bar) :baz)`.

; This expands to
; `(do
;    (. (require :bar.baz) :foo)
;    (. (require :bar.quux) :foo))`.
(subcalls :foo :bar :baz :quux)
```

[Fennel]: https://fennel-lang.org