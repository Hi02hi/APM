import apm

const lim = 1000

echo "Division/Modulo Test"
for j in -lim..lim:
  echo "batch ", j
  if j == 0:continue
  for i in -lim..lim:
    #stdout.write (i, j), " "
    let
      sum = newNumber(i) div newNumber(j)
      ssum = $sum

    #echo sum
    assert ssum == $(i div j), ssum & " != " & $i & " div " & $j & ". expected " & $(i div j)