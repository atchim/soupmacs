; Script for generating a Markdown documentation from Fennel content in stdin.

(local
  {: comment? : eval : list? : parser : sequence? : sym? : table? : view}
  (require :fennel))

(fn get-double-semicols-content [comment*]
  "Returns the content of the double-semicolon `comment*` if present."
  (let [s (tostring comment*) (start end) (s:find "^;;%s?")]
    (when (= 1 start) (s:sub (+ 1 end)))))

(fn get-fn-info [may-fn]
  "Returns the name, parameters and docstring of `may-fn` if it's a function."
  (when (-?> (list? may-fn) (. 1) (sym?) (tostring) (= :fn))
    (let
      [ name (-?> (. may-fn 2) (sym?))
        params (-?> (. may-fn 3) (sequence?))
        docs (. may-fn 4)]
      (when (and name params (= :string (type docs)))
        (values name (view params) docs)))))

(fn get-heading-level [s]
  "Returns the heading level of `s` if present."
  (let [(start end) (s:find "^#+")] (when start (- (+ 1 end) start))))

(fn eval-snippets [docs]
  "Evaluates all Fennel code snippets present in `docs`."
  (var i 1)
  (var keep-finding? true)
  (while keep-finding?
    (let [(start end code) (docs:find "```fennel\n(.-)```" i)]
      (if start (do (eval code) (set i end)) (set keep-finding? false)))))

(fn get-fn-doc [name params docs cur-heading-level]
  "Test and returns the Markdown documentation for the function content."
  (let
    [ hashes (: :# :rep (+ 1 cur-heading-level))
      heading (-> "%s `%s %s`\n" (: :format hashes name params))
      (_ _ offset) (docs:find "\n\n(%s+)")
      docs (if offset (docs:gsub (.. "\n" offset) "\n") docs)
      docs (docs:gsub "```fennel%-no%-run\n" "```fennel\n")
      docs (docs:gsub "\n(#+)" (fn [hashes*] (.. "\n" hashes hashes*)))]
    (.. heading "\n" docs)))

(fn write-md! [src]
  "Extracts the Markdown content from `src` and writes it via `io.write`."
  (var heading-level 0)
  (var last-heading nil)
  (let [parser* (parser src nil {:comments true})]
    (each [ok? node parser*]
      (when ok?
        (if
          (comment? node)
          (match (get-double-semicols-content node)
            nil nil
            "" (do (set last-heading nil) (io.write "\n\n"))
            content
            (let [cur-heading (get-heading-level content)]
              (when (and (not= 0 heading-level) (or cur-heading last-heading))
                (io.write "\n\n"))
              (when cur-heading (set heading-level cur-heading))
              (io.write content)
              (set last-heading cur-heading)))
          (not (or (sym? node) (table? node)))
          (let [(name? params docs) (get-fn-info node)]
            (when name?
              (eval-snippets docs)
              (when (not= 0 heading-level) (io.write "\n\n"))
              (io.write (get-fn-doc name? params docs heading-level)))))))))

(let [stdin (io.stdin:read :*all)] (write-md! stdin))