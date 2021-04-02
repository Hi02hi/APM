import apm

const lim = 100

echo "Subtraction Test"
for j in -lim..lim:
  echo "batch ", j
  for i in -lim..lim:
    let sum = newNumber(i) - newNumber(j)
    
    assert $sum == $(i-j), $sum & " != " & $i & " - " & $j