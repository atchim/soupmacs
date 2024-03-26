# 🍲 Soup Macros

> A collection of useful macros for [Fennel].

## ✔️ Assertion

### `assert-lazy [cond err-msg-cb]` 

Expands to a lazy assertion-like expression.

The expanded expression evaluates the truthiness of `cond`. If `cond` is
truthy, it's returned; otherwise, the error message is generated using
`err-msg-cb` and an error is raised with that message.

This can be useful to defer the evaluation of the error message until it's
actually needed.

#### Examples

```fennel
(import-macros {: assert-lazy} :soupmacs)

(let
  [ key :credentials
    user {:name :John :surname :Doe}
    err-msg-cb #(: "user %s doesn't have %s" :format user.name key)
    (ok? err-msg) (pcall #(assert-lazy (. user key) err-msg-cb))]
  (assert (= false ok?))
  (assert (err-msg:match "^.+: user John doesn't have credentials$")))
```

## ⁉️ Boolean Evaluation

### `any-of? [x ...]` 

Expands to an expression returning if `x` is equal to any value in `...`.

#### Examples

```fennel
(import-macros {: any-of?} :soupmacs)

(let [age 25 country :Hawaii name :McLOVIN]
  (assert (any-of? 25 age country name))
  (assert (not (any-of? :McINLOV age country name)))
  (assert (not (any-of? :Kawaii age country name))))
```

#### Note

Table literals should be avoided to be passed as arguments since they will
never match. Additionally, when using a table literal as an argument for the
`x` parameter, it will be evaluated `n` times, where `n` is the number of
arguments in `...`.

## 🆗 Defaults

### `or-default [value default]` 

Expands to an expression returning non-nil `value` or a `default` one.

#### Examples

```fennel
(import-macros {: or-default} :soupmacs)

(let [foo :foo bar nil]
  (assert (= :foo (or-default foo :bar)))
  (assert (= :baz (or-default bar :baz))))
```

### `or-default-lazy [value default-cb]` 

Like `or-default`, but evaluates `default-cb` when `value` is `nil`.

#### Examples

```fennel
(import-macros {: or-default-lazy} :soupmacs)

(let
  [ sqrt-of-3-fn #(math.sqrt 3)
    lazy-fn #(-> [:I :am :lazy!] (table.concat " "))]
  (assert (= 0 (or-default-lazy 0 sqrt-of-3-fn)))
  (assert (= "I am lazy!" (or-default-lazy nil lazy-fn))))
```

## 📐 Math

### `dec [x]` 

Expands to an expression decrementing `x` by 1 and returning it.

#### Examples

```fennel
(import-macros {: dec} :soupmacs)
(var x 0)
(assert (= -1 (dec x)))
(assert (= -1 x))
```

### `inc [x]` 

Expands to an expression incrementing `x` by 1 and returning it.

#### Examples

```fennel
(import-macros {: inc} :soupmacs)
(var x 0)
(assert (= 1 (inc x)))
(assert (= 1 x))
```

## 🧩 Module Related

### `--> [mod ...]` 

Expands to an access (and optionally a call) of an item of `mod`.

This macro is a shorthand for accessing the module (`mod`). Additional
arguments (`...`) can be provided to specify nested accesses. If the last
argument is a sequence, the expanded code evaluates to a function call of the
accessed item, and the content of the sequence is passed as arguments.

It might be leveraged to avoid the verbosity of importing, accessing and
calling an item in Fennel.

#### Examples

```fennel
(import-macros {: -->} :soupmacs)

; Macro Call                 | Lua Equivalent
(--> :foo)                   ; require'foo'
(--> :foo :bar)              ; require'foo'.bar
(--> :foo :bar [])           ; require'foo'.bar()
(--> :foo :bar [[]])         ; require'foo'.bar{}
(--> :foo :bar [:baz :quux]) ; require'foo'.bar('baz', 'quux')
````

## 🧵 String Manipulation

### `lines [...]` 

Returns the concatenation of `...` with `"\n"`.

#### Examples

```fennel
(import-macros {: lines} :soupmacs)
(assert (= "foo\nbar\nbaz" (lines :foo :bar :baz)))
(assert (= "" (lines)))
```

## ✅ Type Checking

### `of-type? [x ...]` 

Expands to an expression returning if `x` is of any of given `...` types.

The expanded expression also returns the type of `x` as second return value.

#### Examples

```fennel
(import-macros {: of-type?} :soupmacs)

(let [(cond type*) (of-type? 0 :boolean :number)]
  (assert (= true cond))
  (assert (= :number type*)))

(let [(cond type*) (of-type? [] :nil :string)]
  (assert (= false cond))
  (assert (= :table type*)))
```

[Fennel]: https://fennel-lang.org