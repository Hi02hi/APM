import algorithm

type
  Number* = object
    limbs*: seq[uint8]
    negative*: bool
  #Ratio = object
    #num, den: Number

func initNumber*(num: string): Number = 
  # FIXME: needs to go from base 10 to base 256
  let negative = num[0] == '-'
  result.limbs = newSeq[uint8](if negative: num.len - 1 else: num.len)
  result.negative = negative

  for ix, i in num:
    if i == '-':continue
    assert i.ord in 48..57, "must be a digit"
    result.limbs[(if negative: ix-1 else: ix)] = (i.ord - 48).uint8

proc traverse[T](x, y: seq[T]): seq[(T, T)] = 
  # like zip from std/sequtils, but doesn't stop after one seq ends
  for i in 0..max(x.high, y.high):
    var pair: (T, T)
    if i <= x.high: pair[0] = x[i]
    if i <= y.high: pair[1] = y[i]
    result.add pair 

const
  zero* = initNumber("0")
  one* = initNumber("1")

func `$`*(n: Number): string = 
  ## FIXME
  for i in n.limbs: result.add $i
  if n.negative: result = "-" & result

func `-`*(x: Number): Number = 
  result = x
  result.negative = not result.negative

func abs*(x: Number): Number = 
  result = x
  result.negative = false

func cmp*(x, y: Number): int = 
  # doesnt always return 1, -1, or 0
  if x.negative:
    if y.negative: return cmp(-x, -y)
    else: return -1
  else:
    if y.negative: return 1
    else:
      # normal cmp
      if x.limbs.len != y.limbs.len: return cmp(x.limbs.len, y.limbs.len)
      else:
        for i in traverse(x.limbs, y.limbs):
          if i[0] != i[1]: return cmp(i[0], i[1])

func `==`*(x, y: Number): bool = cmp(x, y) == 0
func `>` *(x, y: Number): bool = cmp(x, y) > 0
func `<` *(x, y: Number): bool = cmp(x, y) < 0
func `>=`*(x, y: Number): bool = cmp(x, y) > -1
func `<=`*(x, y: Number): bool = cmp(x, y) < 1

func additionUnsigned*(x, y: Number): Number = 
  ## adds 2 nums
  if x.limbs.len < y.limbs.len: return additionUnsigned(y, x)
  result = x
  var carry = false
  for ix, i in traverse(x.limbs.reversed, y.limbs.reversed):
    let total = i[0].int + i[1].int + carry.int
    #debugEcho ix, " ", i, " ", total
    carry = total >= 256
    result.limbs[^(ix+1)] = if carry: (total-256).uint8 else: total.uint8
  if carry: # we still need to carry
    result.limbs = @[1.uint8] & result.limbs

func subtractionUnsigned*(x, y: Number): Number = 
  # subtracts 2 positive nums
  if x < y: return -(subtractionUnsigned(y, x))
  result = x
  var borrow = false
  for ix, i in traverse(x.limbs.reversed, y.limbs.reversed):
    let total = i[0].int - i[1].int - borrow.int
    #debugEcho ix, " ", i, result.limbs[ix], " ", total
    borrow = total < 0
    result.limbs[^(ix+1)] = if borrow: (total+256).uint8 else: total.uint8
  # there may or may not be zeros at the front, so let's get rid of them
  while result.limbs[0] == 0'u8 and result != zero:
    result.limbs = result.limbs[1..^1]

func `-`*(x, y: Number): Number

func `+`*(x, y: Number): Number = 
  if    y.negative: 
    #[debugEcho "1";]# x - -y
  elif  x.negative:
    #[debugEcho "2";]# y - -x
  else:
    #[debugEcho "3";]# additionUnsigned(x, y)

func `-`*(x, y: Number): Number = 
  if y.negative:
    #[debugEcho "4";]# x + -y
  elif x.negative: 
    #[debugEcho "5";]# -abs(additionUnsigned(x, y))
  else:
    #[debugEcho "6";]# subtractionUnsigned(x, y)

func inc*(x: var Number) = x = x + one

func dec*(x: var Number) = x = x - one

func `+=`*(x: var Number, y: Number) = x = x + y

func `-=`*(x: var Number, y: Number) = x = x - y

iterator countup*(x, y, step: Number): Number = 
  var result = x
  while result < y:
    yield result
    result += step

iterator countdown*(x, y, step: Number): Number = 
  var result = x
  while result > y:
    yield result
    result -= step

iterator `..`*(x, y: Number): Number = 
  for i in countup(x, y, one): yield i

iterator `..<`*(x, y: Number): Number = 
  for i in countup(x, y-one, one): yield i

when isMainModule:
  # testing stuff here, dont mind me... 
  let
    num = initNumber("-100")
    num2 = initNumber("1")

  echo num
  echo num2

  echo num, " + ", num2, " = ", num + num2
  echo "see! i need to go to convert to base 10, those values would have been -65536 + 1 = -[255, 255] = -65535, correct"