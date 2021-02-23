import Apm

# test all combinations of 2 numbers from -100..100
const lim = 100

echo "Addition Test"
for j in -lim..lim:
  echo "batch ", j
  for i in -lim..lim:
    let sum = initNumber($i) + initNumber($j)

    assert $sum == $(i+j), sum.repr & " != " & $i & " + " & $j