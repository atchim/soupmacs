;; # 🍲 Soup Macros
;;
;; > A collection of useful macros for [Fennel].

;; ## ✔️ Assertion

(fn assert-not [x ?msg]
  "Expands to an assertion that `x` evaluates to `false`, with optional `?msg`.

  # Examples

  ```fennel
  (import-macros {: assert-not : assert=} :soupmacs)

  ; Fails without message.
  (let [f #(assert-not true) (ok? errmsg) (pcall f)]
    (assert-not ok?)
    (assert= \"assertion failed!\" errmsg))

  ; Fails with message.
  (let [f #(assert-not 0 \"not false\") (ok? errmsg) (pcall f)]
    (assert-not ok?)
    (assert= \"not false\" errmsg))

  ; Passes.
  (let [f #(assert-not false) (ok? retval) (pcall f)]
    (assert ok?)
    ; In this case `retval` is the value returned from the assertion.
    (assert= true retval))
  ```"
  `(assert (not ,x) ,?msg))

(fn assert= [x y ?msg]
  "Expands to an assertion that `x` is equal to `y`, with optional `?msg`.

  # Examples

  ```fennel
  (import-macros {: assert-not : assert=} :soupmacs)

  ; Fails without message.
  (let [f #(assert= 0 :0) (ok? errmsg) (pcall f)]
    (assert-not ok?)
    (assert= \"assertion failed!\" errmsg))

  ; Fails with message.
  (let [f #(assert= 0 false \"not the same\") (ok? errmsg) (pcall f)]
    (assert-not ok?)
    (assert= \"not the same\" errmsg))

  ; Passes.
  (let [f #(assert= 3 (tonumber :3)) (ok? retval) (pcall f)]
    (assert ok?)
    (assert= true retval))
  ```"
  `(assert (= ,x ,y) ,?msg))

(fn assert-not= [x y ?msg]
  "Expands to an assertion that `x` is not equal to `y`, with optional `?msg`.

  This works similar to [`assert=`](#assert)."
  `(assert (not (= ,x ,y)) ,?msg))

;; ## 🎚 Boolean Evaluation

(fn oneof? [x ...]
  "Expands to an expression returning if `x` is equal to some value in `...`.

  # Examples

  ```fennel
  (import-macros {: oneof?} :soupmacs)
  (let [age 25 country :Hawaii name :McLOVIN]
    (assert (oneof? 25 age country name))
    (assert (not (oneof? :McINLOV age country name)))
    (assert (not (oneof? :Kawaii age country name))))
  ```

  # Note

  Do not pass table literals as arguments, since they will never match. Also,
  passing a table literal as argument for the `x` parameter results in the
  table literal being evaluated `n` times, where `n` is the number of arguments
  of `...`."
  `(or ,(unpack (icollect [_ y (ipairs [...])] `(= ,x ,y)))))

(fn ty= [x ...]
  "Expands to an expresssion returning if `x` has one of given `...` types.

  # Examples

  ```fennel
  (import-macros {: ty=} :soupmacs)
  (assert (ty= 0 :number))
  (assert (ty= [] :nil :table))
  (assert (not (ty= 0 :boolean :string :table)))
  ```"
  `(let [ty# (type ,x)] ,(oneof? `ty# ...)))

;; ## 📐 Math

(fn dec [x]
  "Expands to an expression decrementing `x` by 1 and returning it.

  # Examples

  ```fennel
  (import-macros {: assert= : dec} :soupmacs)
  (var x 0)
  (assert= -1 (dec x))
  (assert= -1 x)
  ```"
  `(do (set ,x (- ,x 1)) ,x))

(fn inc [x]
  "Expands to an expression incrementing `x` by 1 and returning it.

  # Examples

  ```fennel
  (import-macros {: assert= : inc} :soupmacs)
  (var x 0)
  (assert= 1 (inc x))
  (assert= 1 x)
  ```"
  `(do (set ,x (+ 1 ,x)) ,x))

;; ## 🧩 Module Related

(fn modcall [mod ...]
  "Expands to an expression that both accesses and calls a function of `mod`.

  `mod` is the name of the module. Non-last arguments in `...` are treated as
  table field accesses needed to call the function. If `...` has no argument,
  the macro expands to a function call, without arguments, of the object
  returned by `mod`.

  The last argument in `...` always stands for the argument to be passed to the
  function call. If it is a sequence with zero or more than one items, its
  content is unpacked as the arguments to the function.

  # Examples

  ```fennel-no-run
  ; Content of `bubblegum-machine.fnl`

  (fn dispense [flavor coins]
    (if (and coins (>= coins 1))
      (print
        (->
          \"Dispensing bubblegum with flavor %s for %d coins...\"
          (: :format flavor coins)))
      (print \"Insert at least 1 coin!\")))

  (local cheating
    { :dispense
      (fn [flavor]
        (print
          (->
            \"Dispensing bubblegum with flavor %s for free...\"
            (: :format flavor))))})

  (setmetatable
    {}
    { :__index {: cheating : dispense}
      :__call #(print \"This is a bubblegum machine! Do not cheat!\")})
  ```

  ```fennel-no-run
  (import-macros {: modcall} :soupmacs)

  (modcall :bubblegum-machine)
  ;> This is a bubblegum machine! Do not cheat!

  (modcall :bubblegum-machine :dispense :original)
  ;> Insert at least 1 coin!

  (modcall :bubblegum-machine :dispense [:original 2])
  ;> Dispensing bubblegum with flavor original for 2 coins...

  (modcall :bubblegum-machine :cheating :dispense :watermelon)
  ;> Dispensing bubblegum with flavor watermelon for free...
  ```"

  (let
    [ vargs [...]
      vlen (length vargs)
      body [(unpack vargs 1 (- vlen 1))]
      tail (. vargs vlen)]
    `((->
        (require ,mod)
        ,(unpack (icollect [_ ix# (ipairs body)] `(. ,ix#))))
      ,(if (and (sequence? tail) (not= 1 (length tail))) (unpack tail) tail))))

(fn modget [mod ...]
  "Expands to an expression getting an item in `mod`.

  # Examples

  ```fennel-no-run
  ; Content of `foo.fnl`
  {:bar {:baz :baz}}
  ```

  ```fennel-no-run
  (import-macros {: modget} :soupmacs)
  (local baz (modget :foo :bar :baz))
  ```"
  `(-> (require ,mod) (. ,...)))

;; ## 🧵 String Manipulation

(fn concat [sep ...]
  "Returns `...` concatenated with `sep`.

  # Examples

  ```fennel
  (import-macros {: assert= : concat} :soupmacs)
  (assert= :foo.bar.baz (concat :. :foo :bar :baz))
  ```

  # Note

  All arguments passed to this macro must be string literals."
  (tostring (table.concat [...] sep)))

(fn lines [...]
  "Returns `...` concatenated with \"\\n\".

  This is an alias to `(concat \"\\n\" ...)`. See [`concat`](#concat-sep-).

  # Examples

  ```fennel
  (import-macros {: assert= : lines} :soupmacs)
  (assert= \"foo\\nbar\\nbaz\" (lines :foo :bar :baz))
  ```"
  (concat "\n" ...))

;; ## 🧰 Misc

(fn nonnil [...]
  "Expands to a expression filtering non-nil values of `...` to a new table.

  # Examples

  ```fennel
  (import-macros {: nonnil} :soupmacs)
  (fn sum [t] (accumulate [sum 0 _ n (ipairs t)] (+ sum n)))
  (assert (= 8 (sum (nonnil -1 1 nil 3 5))))
  ```"
  `(icollect [_# v# (values next [,...])] v#))

(fn ordef [val def]
  "Expands to an expression returning non-nil `val` or a `def` one.

  # Examples

  ```fennel
  (import-macros {: ordef} :soupmacs)
  (let [?t nil t {}] (assert (= t (ordef ?t t))))
  (assert (= (ordef false true) false))
  (assert (= (ordef 0 1) 0))
  (assert (= (ordef \"\" :foo) \"\"))
  ```"
  `(if (not= nil ,val) ,val ,def))

(fn whenot [cond ...]
  "Expands to `(when (not cond) ...)`."
  `(when (not ,cond) ,...))

;; [Fennel]: https://fennel-lang.org

{ : assert-not
  : assert-not=
  : assert=
  : concat
  : dec
  : inc
  : lines
  : modcall
  : modget
  : nonnil
  : oneof?
  : ordef
  : ty=
  : whenot}
