import bigints

type
  ratio* = object
    num*, den*: number

func newRatio*(x, y: number): ratio = 
  if y == zero:
    raise newException(DivByZeroError, "Division by 0")
  result = ratio(num: x, den: y)
  if x < zero and y < zero:
    result = ratio(num: -x, den: -y)

func newRatio*(x, y: int): ratio = 
  newRatio(x.newNumber, y.newNumber)

func `//`*(x, y: number): ratio = newRatio(x, y)

func reciprocal*(x: ratio): ratio = 
  newRatio(x.den, x.num)

func gcd(x, y: number): number = 
  # Euclid's algorithm for gcd
  if y == zero: x else: gcd(y, x mod y)
  # yes, gcd is that simple, note it only works on positives i think

func reduce*(x: ratio): ratio = 
  let common = gcd(x.num, x.den)
  newRatio(x.num div common, x.den div common)

func fix(x: var ratio) = 
  if x.den < zero:
    # the denominator is negative, mul by -1/-1
    x.num = -x.num
    x.den = -x.den

func fix(x: ratio): ratio = 
  result = x
  fix result

func mul(x: ratio, y: number): ratio = 
  newRatio(x.num * y, x.den * y)

func `+`*(x, y: ratio): ratio = 
  let
    a = mul(x, y.den)
    b = mul(y, x.den)
  fix reduce newRatio(a.num + b.num, a.den)

func `-`*(x: ratio): ratio = 
  result = x
  result.num = -result.num
  fix result

func `-`*(x, y: ratio): ratio = 
  result = x
  result = result + -y

func `*`*(x, y: ratio): ratio = 
  fix reduce newRatio(x.num * y.num, x.den * y.den)

func `/`*(x, y: ratio): ratio = 
  fix reduce x*y.reciprocal

func cmp*(x, y: ratio): int = 
  let
    a = reduce x
    b = reduce y
  cmp(a.num * b.den, a.den * b.num)

func `==`*(x, y: ratio): bool = cmp(x, y) == 0
func `>`*(x, y: ratio): bool = cmp(x, y) > 0
func `<`*(x, y: ratio): bool = cmp(x, y) < 0
func `>=`*(x, y: ratio): bool = cmp(x, y) > -1
func `<=`*(x, y: ratio): bool = cmp(x, y) < -1

func `$`*(x: ratio): string = 
  $x.num & "/" & $x.den

when isMainModule:
  import rationals
  for i in 1..100:
    for j in 1..100:
      let
        home = i.newNumber//j.newNumber
        away = i//j
      assert $(home+home) == $(away+away)