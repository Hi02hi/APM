import Apm

const lim = 1_000

echo "Subtraction Test"
for step in 0..lim:
  echo step
  for i in step..lim:
    let sum = initNumber($i) - initNumber($(i-step))
    
    #echo i, " ", i-step, " ", sum
    assert $sum == $(i-(i-step)), $sum & " != " & $i & " - " & $(i-step)