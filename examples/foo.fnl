(let [t {:__call (lambda [_self ...] (icollect [_ arg (ipairs [...])] arg))}]
  (set t.__index #t)
  (setmetatable t t))
