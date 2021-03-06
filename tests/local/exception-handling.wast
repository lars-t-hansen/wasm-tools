;; --enable-exceptions --enable-multi-value
(module 
  (type (func (param i32 i64)))
  (type (func (param i32)))
  (event (type 0))
  (event (type 1))
  (func $check-throw
    i32.const 1
    i64.const 2
    throw 0
  )
  (func $check-try-catch-rethrow
    try (result i32 i64)
      call $check-throw
      unreachable
    catch 0
      ;; the exception arguments are on the stack at this point
    catch 1
      i64.const 2
    catch_all
      rethrow 0
    end
    drop
    drop
  )
  (func $check-unwind (local i32)
    try
      i32.const 1
      local.set 0
      call $check-throw
    unwind
      i32.const 0
      local.set 0
    end
  )
)

(assert_invalid
  (module
    (type (func))
    (func throw 0))
  "unknown event: event index out of bounds")

(assert_invalid
  (module
    (func try catch_all catch_all end))
  ;; we can't distinguish between `catch_all` and `else` in error cases
  "else found outside of an `if` block")

(assert_invalid
  (module
    (func try catch_all catch 0 end))
  "catch found outside of an `try` block")

(assert_invalid
  (module
    (func try unwind i32.const 1 end))
  "type mismatch: values remaining on stack at end of block")

(assert_invalid
  (module
    (func block try catch_all rethrow 1 end end))
  "rethrow target was not a `catch` block")
