# Soup Macros

> A collection of useful macros for [Fennel].

## Usage

Pass the `--add-macro-path` argument with the path to the `soupmacs.fnl` file
to the `fennel` command in order to be able to import and use the macros. The
following snippets exemplify that.

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

Non-last arguments in `...` are treated as the accesses needed in order to
call the function. For example, using `(modcall :foo :bar :baz)` expands to
`((. (require :foo) :bar) :baz)`.

#### Examples

```fennel
(modcall :foo) ; Expands to `((require :foo))`.
(modcall :foo :bar) ; Expands to `((require :foo) :bar)`.
(modcall :foo (:bar)) ; Expands to the same as the last one.
(modcall :foo :bar :baz) ; Expands to `((. (require :foo) :bar) :baz)`.
(modcall :foo (:bar :baz)) ; Expands to `((require :foo) :bar :baz)`.
```

### `modget? [mod ...]`

Expands to an access of `mod` and, optionally its `...` nested items.

#### Examples

```fennel
(modget? :foo) ; Expands to `(require :foo)`.
(modget? :foo :bar) ; Expands to `(?. (require :foo) :bar)`.
(modget? :foo :bar :baz) ; Expands to `(?. (require :foo) :bar :baz)`.
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

`val` is bound to a local variable in order to avoid evaluating it twice.

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