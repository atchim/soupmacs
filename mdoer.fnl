; Markdown writer based on Fennel content in `stdin`.

(local
  { : comment?
    : eval
    : list?
    : parser
    : sequence?
    : sym?
    : table?
    : view}
  (require :fennel))

(fn double-semicols? [comment*]
  "Returns the content of the double-semicolon `comment*` if present."
  (let [s (tostring comment*) (start end) (s:find "^;;%s?")]
    (when (= 1 start) (s:sub (+ 1 end)))))

(fn fn? [may-fn]
  "Returns the name, parameters and docstring of `non-sym` if it is function."
  (when (-?> (list? may-fn) (. 1) (sym?) (tostring) (= :fn))
    (let
      [ name (-?> (. may-fn 2) (sym?))
        params (-?> (. may-fn 3) (sequence?))
        docs (. may-fn 4)]
      (when (and name params (= :string (type docs)))
        (values name (view params) docs)))))

(fn h-level? [s]
  "Returns the header level of `s` if present."
  (let [(start end) (s:find "^#+")] (when start (- (+ 1 end) start))))

(fn eval-snippets [docs]
  "Evaluates all Fennel code snippets present in `docs`."
  (var i 1)
  (var finding? true)
  (while finding?
    (let [(start end code) (docs:find "```fennel\n(.-)```" i)]
      (if start (do (eval code) (set i end)) (set finding? false)))))

(fn write-fn-md [name params docs cur-h-level]
  "Writes the Markdown documentation for the function content and test it."
  (let
    [ h (: :# :rep (+ 1 cur-h-level))
      header (-> "%s `%s %s` \n" (: :format h name params))
      (_ _ offset) (docs:find "\n\n(%s+)")
      docs (if offset (docs:gsub (.. "\n" offset) "\n") docs)
      docs (docs:gsub "```fennel%-no%-run\n" "```fennel\n")
      docs (docs:gsub "\n(#+)" (fn [h*] (.. "\n" h h*)))]
    (io.write header "\n" docs)))

(fn write-md [src]
  "Extracts the Markdown content from `src` and writes it via `io.write`."
  (var h-level 0)
  (var h-last nil)
  (let [parser* (parser src nil {:comments true})]
    (each [ok? node parser*]
      (when ok?
        (if
          (comment? node)
          (match (double-semicols? node)
            nil nil
            "" (do (set h-last nil) (io.write "\n\n"))
            ds
            (let [h-cur (h-level? ds)]
              (when (and (not= 0 h-level) (or h-cur h-last)) (io.write "\n\n"))
              (when h-cur (set h-level h-cur))
              (io.write ds)
              (set h-last h-cur)))
          (not (or (sym? node) (table? node)))
          (let [(name? params docs) (fn? node)]
            (when name?
              (eval-snippets docs)
              (when (not= 0 h-level) (io.write "\n\n"))
              (write-fn-md name? params docs h-level))))))))

(let [stdin (io.stdin:read :*all)] (write-md stdin))
