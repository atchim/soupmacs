(local M {})

(fn M.modcall [mod ...]
  "Expands to a function call into `mod`.

  `mod` must be a string naming the module. The last argument in `...` always
  stands for the argument to be passed to the function call. If it is a list,
  its content is unpacked as the arguments to the function. For instance, using
  `(modcall :foo (:bar :baz))` expands to `((require :foo) :bar :baz)`. If
  `...` has no argument, the macro expands to a function call, without
  arguments, of the object returned by `mod`.

  Non-last arguments in `...` are treated as the accesses needed to call the
  function. For example, using `(modcall :foo :bar :baz)` expands to
  `((. (require :foo) :bar) :baz)`.

  # Examples

  ```fennel
  (modcall :foo) ; Expands to `((require :foo))`.
  (modcall :foo :bar) ; Expands to `((require :foo) :bar)`.
  (modcall :foo (:bar)) ; Expands to the same as the last one.
  (modcall :foo :bar ()) ; Expands to `((. (require :foo) :bar))`.
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
  "Expands to access of `mod` and, optionally its `...` nested items.

  # Examples

  ```fennel
  (modget? :foo) ; Expands to `(require :foo)`.
  (modget? :foo :bar) ; Expands to `(?. (require :foo) :bar)`.
  (modget? :foo :bar :baz) ; Expands to `(?. (require :foo) :bar :baz)`.
  ```"
  `(-> (require ,mod) (?. ,...)))

(fn M.nonnil [t]
  "Expands to a filtering of non-nil values from `t` to a new table.

  # Note

  If `t` has negative-indexed values, the returned table is not guaranteed to
  be sorted.

  # Examples

  ```fennel
  (let
    [ t (nonnil {-1 -1 1 1 2 nil 3 3 5 5})
      sum (accumulate [sum 0 _ n (ipairs t)] (+ sum n))]
    (assert (= sum 8)))
  ```"

  `(let [t# ,t non-nil# {}]
     (each [k# v# (values next t#)]
       (match (type k#)
         :number (table.insert non-nil# v#)
         _# (tset non-nil# k# v#)))
     non-nil#))

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

  # Examples

  ```fennel
  (let [t {}] (assert (= (ordef nil t) t)))
  (assert (= (ordef false true) false))
  (assert (= (ordef 0 1) 0))
  (assert (= (ordef \"\" :foo) \"\"))
  ```"
  `(if (not= nil ,val) ,val ,def))

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

(fn M.ty= [x ...]
  "Expands returning whether `x` has one of given `...` types.

  # Examples

  ```fennel
  (assert (not (ty= 0 :boolean)))
  (assert (ty= 0 :number))
  (assert (ty= {} :nil :table))
  (assert (not (ty= 0 :boolean :string :table)))
  ```"
  `(let [ty# (type ,x)] ,(M.oneof? `ty# ...)))

M
