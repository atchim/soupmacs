(import-macros {: ty=} :soupmacs)

(local M {})

(set M.some? (lambda some? [?x] (not= nil ?x)))

(set M.like?
  (lambda like? [?x ?y]
    (if (and (ty= ?x :table) (ty= ?y :table))
      (do
        (var (eq? ?xi ?yi) (values true (next ?x) (next ?y)))
        (if
          (= nil ?xi) (set eq? (= nil ?yi))
          (= nil ?yi) (set eq? (= nil ?xi)))
        (while (and eq? (some? ?xi) (some? ?yi))
          (set eq?
            (let [xitem (. ?x ?xi) yitem (. ?y ?xi)]
              (and
                (like? xitem yitem)
                (let [xitem (. ?x ?yi) yitem (. ?y ?yi)]
                  (like? xitem yitem)))))
          (set (?xi ?yi) (values (next ?x ?xi) (next ?y ?yi)))
          (when eq? (when (= nil ?xi) (set eq? (= nil ?yi)))))
        eq?)
      (= ?x ?y))))

M
