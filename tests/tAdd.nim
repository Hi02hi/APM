import apm

const lim = 1000

echo "Addition Test"
for j in -lim..lim:
  echo "batch ", j
  for i in -lim..lim:
    let
      sum = newNumber(i) + newNumber(j)
      ssum = $sum

    assert ssum == $(i+j), ssum & " != " & $i & " + " & $j