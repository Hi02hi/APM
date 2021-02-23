import Apm

# test all combinations of 2 numbers from -1000..1000
const lim = 1_000

echo "Subtraction Test"
for j in -lim..lim:
  echo "batch ", j
  for i in -lim..lim:
    let sum = initNumber($i) - initNumber($j)
    
    assert $sum == $(i-j), $sum & " != " & $i & " - " & $j