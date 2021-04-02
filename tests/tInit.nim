import apm

# test all combinations of 2 numbers from -100..100
const lim = 100

echo "Initiation Test"
for i in -lim..lim:
  let
    x = newNumber(i)
    y = newNumber($i)
  assert x == y,
    $i & ": " & $x & " != " & $y