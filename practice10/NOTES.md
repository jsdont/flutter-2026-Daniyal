# Practice 10

## Level 1 — Event order

My prediction was `A → C → first frame → B → 6 students`. The Flutter test
device showed the same order, with one extra log from the API:

```text
A
C
fetchStudents #1
first frame at 796 ms
B
6 students
```

Both timers started before the first frame. With `sleep` in place of
`await Future.delayed`, the first frame appeared at 2512 ms. The third
fetch without an error handler reported `Instance of 'NoConnectionException'`.

## Level 2 — Leaving during a load

I removed the two `mounted` checks in a test copy and left the screen
while the request was loading. When it finished, Flutter printed:

```text
Exception: setState() called after dispose(): _StudentsScreenState#de74e(lifecycle state: defunct, not mounted)
```

The final screen checks `mounted` before updating the list or the error.

## Level 3 — FutureBuilder

Ten flips of the compact switch produced just one `fetchStudents #1`.
With the request inside `build`, two flips started requests #2 and #3.
The spinner returned and request #3 failed. Checking for missing data
before checking for an error left the spinner on screen after that failure.

## Level 4 — Countdown

- **Listen, with cancel:** I left at 7. The last log was `tick 7`.
- **Listen, without cancel:** After Back, the log continued from `tick 6`
  to `tick 0`. Each tick tried to call `setState()` on the closed screen.
  The test kept running to record all the ticks.
- **StreamBuilder:** I left at 7. The last log was `tick 7` because
  StreamBuilder cancels its own subscription.

## Level 5 — Save

Without `await`, the second Save closed the screen immediately. It looked
successful to the user. A second later the test device printed:

```text
[ERROR:flutter/shell/testing/tester_main.cc(622)] Unhandled exception
Exception: Bad state: server rejected 6
```

The analyzer flagged the missing `await` in the async Save method.
The final button waits for the result. A successful save goes back.
A rejected save stays on the list and shows `server rejected 6`.
