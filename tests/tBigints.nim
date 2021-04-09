import unittest, apm/bigints

test "Addition Test":
  for i in -1000..1000:
    for j in 1000..1000:
      let
        sum = i.newNumber + j.newNumber
        result = $sum
      
      assert result == $(i+j), $( (i, j) ) & ", " & $(i+j) & " != " & result

test "Subtraction Test":
  for i in -1000..1000:
    for j in 1000..1000:
      let
        sum = i.newNumber - j.newNumber
        result = $sum
      
      assert result == $(i-j), $( (i, j) ) & ", " & $(i-j) & " != " & result

test "Multiplacation Test":
  for i in -1000..1000:
    for j in 1000..1000:
      let
        sum = i.newNumber * j.newNumber
        result = $sum
      
      assert result == $(i*j), $( (i, j) ) & ", " & $(i*j) & " != " & result

test "DivMod Test":
  for i in -1000..1000:
    for j in 1000..1000:
      let
        sum = divMod(i.newNumber, j.newNumber)
        result = $sum
      
      assert result == $((d: i div j, m: i mod j)), $( (i, j) ) & ", " & $((i div j, i mod j)) & " != " & result

test "Initiation Test":
  # making sure all ways of initiation (int, string, uint8) result in the same number
  for i in -1000..1000:
    let
      a = i.newNumber
      b = ($i).newNumber
    assert a == b, $i & ", " & $a & " != " & $b
    if i < 256 and i >= 0:
      let c = i.uint8.newNumber
      assert a == c