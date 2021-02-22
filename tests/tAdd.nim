import Apm

const lim = 1_000

echo "Addition Test"
for step in 0..lim:
  for i in step..lim:
    let sum = initNumber($i) + initNumber($(i-step))
    
    assert $sum == $(i+i-step), $sum & " != " & $i & " + " & $(i-step)
  echo step