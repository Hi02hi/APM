import apm

const lim = 1000

echo "Comparison Test"
for j in -lim..lim:
  echo "batch ", j
  for i in -lim..lim:

    assert cmp(i, j) == cmp(i.newNumber, j.newNumber), 
      $((i, j)) & ", " & $(cmp(i, j)) & " != " & $(cmp(i.newNumber, j.newNumber))
