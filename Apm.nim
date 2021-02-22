import strutils, algorithm

const base = 10.uint8

type
  Base10Digits = range[0'u8..base-1.uint8]
  Number* = object
    limbs*: seq[Base10Digits]
    negative*: bool
  #Ratio = object
    #num, den: Number

func initNumber*(num: string): Number = 
  # TODO: figure out how to convert base 10 to other bases for when i go to full uint8's
  if num[0] == '-': result.negative = true

  for i in num:
    if i == '-':continue
    if i notin Digits:
      raise newException(ValueError, "must be a base 10 digit")
    result.limbs.add ($i).parseInt.uint8

func `$`*(n: Number): string = 
  for i in n.limbs: result.add $i
  if n.negative: result = "-" & result

const
  zero = initNumber("0")
  one = initNumber("1")

proc traverse[T](x, y: seq[T]): seq[(T, T)] = 
  ## like zip, but doesn't stop after one seq ends
  for i in 0..max(x.high, y.high):
    var pair: (T, T)
    if i <= x.high: pair[0] = x[i]
    if i <= y.high: pair[1] = y[i]
    result.add pair 

func `+`*(x, y: Number): Number = 
  ## adds 2 positive nums
  #if x.limbs.len < y.limbs.len: return y + x
  result = x
  var carry = false
  for ix, i in traverse(x.limbs.reversed, y.limbs.reversed):
    let total = i[0].int + i[1].int + carry.int
    #debugEcho ix, " ", i, " ", total
    carry = total >= base.int
    result.limbs[^(ix+1)] = if carry: (total-base.int).uint8 else: total.uint8
  if carry: # we still need to carry
    result.limbs = @[1.Base10Digits] & result.limbs

func inc*(x: var Number) = x = x + one

func `+=`*(x: var Number, y: Number) = x = x + y

# #[
func `-`*(x, y: Number): Number = 
  # subtracts 2 positive nums, assuming that x > y
  result = x
  var borrow = false
  for ix, i in traverse(x.limbs.reversed, y.limbs.reversed):
    let total = i[0].int - i[1].int - borrow.int
    #debugEcho ix, " ", i, result.limbs[ix], " ", total
    borrow = total < 0
    result.limbs[^(ix+1)] = if borrow: (total+base.int).uint8 else: total.uint8
  # there may or may not be zeros at the front, so let's get rid of them
  while result.limbs[0] == 0'u8 and result != zero:
    result.limbs = result.limbs[1..^1]
# ]#

func `-`*(x: Number): Number = 
  result = x
  result.negative = not result.negative

func abs*(x: Number): Number = 
  result = x
  result.negative = false

func `-=`*(x: var Number, y: Number) = x = x - y

when isMainModule:
  let
    num = initNumber("110")
    num2 = initNumber("89")

  echo num
  echo num2

  echo num - num2