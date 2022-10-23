(local M {})

(fn M.modcall [mod ...]
  "Expands to a function call into `mod`.

  `mod` must be a string naming the module. The last argument in `...` always
  stands for the argument to be passed to the function call. If it is a list,
  its content is unpacked as the arguments to the function. For instance, using
  `(modcall :foo (:bar :baz))` expands to `((require :foo) :bar :baz)`. If
  `...` has no argument, the macro expands to a function call, without
  arguments, of the object returned by `mod`.

  Non-last arguments in `...` are treated as the accesses needed in order to
  call the function. For example, using `(modcall :foo :bar :baz)` expands to
  `((. (require :foo) :bar) :baz)`.

  # Examples

  ```fennel
  (modcall :foo) ; Expands to `((require :foo))`.
  (modcall :foo :bar) ; Expands to `((require :foo) :bar)`.
  (modcall :foo (:bar)) ; Expands to the same as the last one.
  (modcall :foo :bar :baz) ; Expands to `((. (require :foo) :bar) :baz)`.
  (modcall :foo (:bar :baz)) ; Expands to `((require :foo) :bar :baz)`.
  ```"

  (let
    [ args [...]
      nargs (length args)
      fargs (. args nargs)
      fstems [(unpack args 1 (- nargs 1))]]
    `((->
        (require ,mod)
        ,(unpack (icollect [_ fstem# (ipairs fstems)] `(. ,fstem#))))
      ,(if (list? fargs) (unpack fargs) fargs))))

(fn M.modget? [mod ...]
  "Expands to an access of `mod` and, optionally its `...` nested items.

  # Examples

  ```fennel
  (modget? :foo) ; Expands to `(require :foo)`.
  (modget? :foo :bar) ; Expands to `(?. (require :foo) :bar)`.
  (modget? :foo :bar :baz) ; Expands to `(?. (require :foo) :bar :baz)`.
  ```"
  `(-> (require ,mod) (?. ,...)))

(fn M.oneof? [x ...]
  "Expands to an `or` form, like `(or (= x y) (= x z) ...)`.

  # Examples

  ```fennel
  (oneof? x y) ; Expands to `(= x y)`.
  (oneof? x y z) ; Expands to `(or (= x y) (= x z))`.
  (oneof? x y z a) ; Expands to `(or (= x y) (= x z) (= x a))`.
  ```"
  `(or ,(unpack (icollect [_ y (ipairs [...])] `(= ,x ,y)))))

(fn M.ordef [val def]
  "Expands to an `if` expression that returns a non-nil `val` or its `def`.

  `val` is bound to a local variable in order to avoid evaluating it twice."
  `(let [val# ,val] (if (not= nil val#) val# ,def)))

(fn M.subcalls [func mod ...]
  "Expands to function calls of `func` for each `...` submodules of `mod`.

  # Examples

  ```fennel
  (subcalls :foo :bar :baz) ; Expands to `(. (require :foo.bar) :baz)`.

  ; This expands to
  ; `(do
  ;    (. (require :bar.baz) :foo)
  ;    (. (require :bar.quux) :foo))`.
  (subcalls :foo :bar :baz :quux)
  ```"
  `(do
    ,(unpack
      (icollect [_ sub (ipairs [...])]
        `((-> ,(.. mod :. sub) (require) (. ,func)))))))

M
