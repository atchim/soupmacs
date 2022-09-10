(local fennel (require :fennel))

(fn walk-tree [root predicate iter]
  "`iter`ates through`root`'s children applying the `predicate`."
  (local iter (or iter pairs))
  (fn walk [parent idx node]
    "Walks recursively applying the predicate function."
    (when (predicate idx node parent)
      (each [k v (iter node)]
        (walk node k v))))
  (walk nil nil root))

(fn fetch-funcs [filename predicate]
  "Fetches functions from `filename` if they meets `predicate`."

  (var fetched {})

  (fn fetch [_ node _]
    "Fetches `node`'s function information if it is a function."
    (when
      (and
        ; Performs some duck typing.
        (= :table (type node))
        (not (fennel.sym? node))
        (= :fn (tostring (. node 1)))
        (= :table (type (. node 3)))
        (= :string (type (. node 4))))
      (let
        [ func {}
          params (fennel.view (. node 3))
          params (if (= "{}" params) "[]" params)]
        (set func.name (tostring (. node 2)))
        (set func.params params)
        (set func.docs (. node 4))
        (when (predicate func)
          (table.insert fetched func)))
      true))

  (fn fetch-iter [read]
    "Iterates over `read` fetching functions."
    (let [(ok? parsed) (read)]
      (when ok?
        (if (= :table (type parsed))
          (walk-tree parsed fetch))
        (fetch-iter read))))

  (with-open [f (assert (io.open filename :r))]
    (let
      [ contents (assert (f:read :*all))
        read (fennel.parser (fennel.string-stream contents))]
      (fetch-iter read)))
  fetched)

(fn make-md [input template hn]
  "Returns the Markdown string from the `input`'s module functions.

  `template` prepends the fetched Markdown string. `hn` is the base header
  level which will increase each header contained inside function's docstrings
  (e.g., with `hn` set to 3, `# Foo` becomes `#### Foo`)."

  (var template template)

  (fn make [func]
    "Appends the Markdown string from the `func`'s docstring to the template."
    (let
      [ hashes (: :# :rep hn)
        func-name (func.name:gsub :^M%. "")
        header (.. hashes " `" func-name " " func.params "`\n")
        (_ _ offset) (func.docs:find "\n\n(%s+)")
        docs (if offset (func.docs:gsub (.. "\n" offset) "\n") func.docs)
        docs (docs:gsub "\n(#+)" (fn [cap] (.. "\n" hashes cap)))]
      (set template (.. template "\n\n" header "\n" docs))))

  (fn modfn [func]
    "Filters module functions only."
    (when (= 1 (func.name:find "M." 1 true))
      true))

  (local funcs (fetch-funcs input modfn))
  (each [idx func (ipairs funcs)]
    (make func))
  template)

(fn parse-args [args]
  "Parses and runs the `args`."

  (local help
    "utils

Util functions.

USAGE
  fennel utils.fnl <CMD>
  fennel utils.fnl -h

CMD
  md <input> <template> <hn>
    Outputs the Markdown string from the `input`'s module functions.

    `template` prepends the fetched Markdown string. `hn` is the base header
    level which will increase each header contained inside function's
    docstrings (e.g., with `hn` set to 3, `# Foo` becomes `#### Foo`). `hn`
    defaults to 2.

OPTS
  -h --help
    Prints the help information.")

  (fn parse-md [args]
    (let
      [ input (assert (. args 1) "missing `input` argument")
        template (assert (. args 2) "missing `template` argument")
        hn (. args 3)
        hn (if hn (tonumber hn) 2)]
      (print (make-md input template hn))))
  
  (match (. args 1)
    (where cmd (or (= :-h cmd) (= :--help cmd))) (print help)
    :md (parse-md [(unpack args 2)])
    cmd (error (.. "invalid command: " cmd))))

(parse-args arg)
