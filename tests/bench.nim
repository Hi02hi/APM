import nimbench, bigints, bignum, Apm

bench(Addition):
  for i in 1..1000:
    var x = initNumber($i) + initNumber($(i*i))
    doNotOptimizeAway(x)

benchRelative(Proper Addition):
  for i in 1..1000:
    var x = initBigInt($i) + initBigInt($(i*i))
    doNotOptimizeAway(x)

benchRelative(GMP Addition):
  for i in 1..1000:
    var
      result = newInt()
      x = newInt($i, 10)
      y = newInt($(i*i), 10)
    
    discard add(result, x, y) # i think this means put x+y into result, then return result

bench(Subtraction):
  for i in 1..1000:
    var x = initNumber($(i)) - initNumber($(i*i))
    doNotOptimizeAway(x)

benchRelative(Proper Subtraction):
  for i in 1..1000:
    var x = initBigInt(i) - initBigInt(i*i)
    doNotOptimizeAway(x)

benchRelative(GMP Subtraction):
  for i in 1..1000:
    var
      result = newInt()
      x = newInt($i, 10)
      y = newInt($(i*i), 10)
    
    discard add(result, x, y)

runBenchmarks()