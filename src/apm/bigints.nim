type
  number* = object
    negative: bool
    limbs: seq[uint8]

func reversed[T: seq[uint8] | string](arr: T): T {.noInit.} = 
  result = 
    when T is string:
      newStringofCap(arr.len)
    else:
      newSeqofCap[uint8](arr.len)
  for i in countdown(arr.high, 0):
    result.add arr[i]

iterator traverse(x, y: seq[uint8]): (int, uint8, uint8) = 
  # like zip from std/sequtils, but doesn't stop after one seq ends
  for i in 0..max(x.high, y.high):
    var pair = (i, 0'u8, 0'u8)
    if i <= x.high: pair[1] = x[i]
    if i <= y.high: pair[2] = y[i]
    yield pair

func newNumber*(num: uint8): number = 
  number(limbs: @[num], negative: false)

func normalize(num: var number) {.inline.} = 
  # cut off zeros off the front
  var start = 0
  for ix, i in num.limbs:
    if i > 0 or ix == num.limbs.high:
      start = ix
      break
  num.limbs = num.limbs[start..^1]

func newNumber*[T: SomeInteger](num: T): number =
  ## generic int -> number func. WARNING: doesnt work at compile time
  func safe(num: T): uint64 {.inline.} = 
    when T is SomeUnsignedInt: num.uint64 # uints dont have abs()
    else: num.abs.uint64

  when T is SomeSignedInt: result.negative = num < 0

  result.limbs = `@`(cast[array[8, uint8]](num.safe)).reversed
  # BEWARE!: this doesnt work at compile time w. nim v1.2.0
  result.normalize

const
  zero* = newNumber(0'u8)
  one* = newNumber(1'u8)

func `-`*(x: number): number = 
  ## negation
  result = x
  result.negative = not result.negative

func abs*(x: number): number = 
  result = x
  result.negative = false

func cmp*(x, y: number): int = 
  ## Extends cmp to numbers.
  ## returns 1 if x > y
  ## returns 0 if x == y
  ## returns -1 if x < y
  if x.negative:
    return if y.negative: -cmp(-x, -y) else: -1
  else:
    if y.negative: return 1
    else:
      if x.limbs.len != y.limbs.len: return cmp(x.limbs.len, y.limbs.len)
      else:
        for _, a, b in traverse(x.limbs, y.limbs):
          let test = cmp(a, b)
          if test != 0:
            # a != b
            return test

func `==`*(x, y: number): bool = cmp(x, y) == 0
func `>` *(x, y: number): bool = cmp(x, y) > 0
func `<` *(x, y: number): bool = cmp(x, y) < 0
func `>=`*(x, y: number): bool = cmp(x, y) > -1
func `<=`*(x, y: number): bool = cmp(x, y) < 1

func add*(x, y: number): number = 
  ## adds 2 numbers
  if x.limbs.len < y.limbs.len: return add(y, x)
  result = x
  var carry = false
  for ix, a, b in traverse(x.limbs.reversed, y.limbs.reversed):
    #if ix > y.limbs.len and not carry:return
    let total = a.int16 + b.int16 + carry.int16
    #debugEcho ix, " ", (a, b), " ", total
    carry = total >= 256'i16
    result.limbs[^(ix+1)] = cast[uint8](total)
    # (if carry: total-256'i16 else: total).uint8
  if carry: # we still need to carry a one
    result.limbs = @[1'u8] & result.limbs

func sub*(x, y: number): number = 
  ## subtracts 2 positive numbers
  if x < y: return -sub(y, x)
  result = x
  var borrow = false
  for ix, a, b in traverse(x.limbs.reversed, y.limbs.reversed):
    let total = a.int16 - b.int16 - borrow.int16
    #debugEcho ix, " ", i, result.limbs[ix], " ", total
    borrow = total < 0'i16
    result.limbs[^(ix+1)] = (if borrow: total+256'i16 else: total).uint8
  result.normalize

func `-`*(x, y: number): number

func `+`*(x, y: number): number =
  ## addition
  if y.negative: x - -y
  elif x.negative: y - -x
  else: add(x, y)

func `-`*(x, y: number): number = 
  ## subtraction
  if y.negative: x + -y
  elif x.negative: -abs(add(x, y))
  else: sub(x, y)

func inc*(x: var number) = x = x + one

func dec*(x: var number) = x = x - one

func `+=`*(x: var number, y: number) = x = x + y

func `-=`*(x: var number, y: number) = x = x - y

iterator countup*(x, y, step: number): number = 
  var i = x
  while i <= y:
    yield i
    i += step

iterator countdown*(x, y, step: number): number = 
  var i = x
  while i >= y:
    yield i
    i -= step
  yield i

iterator `..`*(x, y: number): number = 
  for i in countup(x, y, one):
    yield i

iterator `..<`*(x, y: number): number = 
  for i in countup(x, y-one, one):
    yield i

func mul(x: number, y: uint8): number = 
  result = x
  var carry: uint16 # maybe can get away with uint8?
  
  for ix, i in x.limbs.reversed:
    let
      total = (i.uint16 * y.uint16) + carry
      conv = cast[array[2, uint8]](total)
    carry = conv[1].uint16
    result.limbs[^(ix+1)] = conv[0]
  if carry > 0:
    result.limbs = @[carry.uint8] & result.limbs

func `*`*(x, y: number): number = 
  ## multiplication
  if y == zero or x == zero: return zero
  if y < zero: return -(x * -y)
  # digit by digit multiplication
  result = zero

  for ix, i in y.limbs.reversed:
    var digit = mul(x, i)
    #debugEcho x, i, digit
    digit.limbs.setLen(digit.limbs.len + ix)
    result += digit

func `*=`*(x: var number, y: number) = x = x * y

func `shl`*(x, y: number): number = 
  ## bitshift left
  result = x
  for i in one..y:
    result *= newNumber(2'u8)

func divMod*(x, y: number): tuple[d, m: number] = 
  if y == zero:
    raise newException(DivByZeroError, "Division by 0")
  if x == zero: return (zero, zero)
  if x.negative or y.negative:
    result = divMod(abs(x), abs(y))
    if (x.negative xor y.negative):
      # -x/-y = x/y, so i dont always want to make it negative
      result.d = -result.d
      result.m = -result.m
    # turn -0 into 0
    if -result.d == zero:
      result.d = -result.d
    if -result.m == zero:
      result.m = -result.m
    return
  # unsigned long division

  func find(n: number): uint8 = 
    # can do binary search here
    for i in 1'u8..255:
      if mul(y, i) > n:
        return i-1
    return 255'u8

  result[0].limbs.setLen(x.limbs.len)

  result[1] = newNumber(x.limbs[0])
    
  for ix, i in x.limbs:
    let digit = find(result[1])
    #debugEcho ix, " ", i, " ", digit, result[1]
    result[0].limbs[ix] = digit
    result[1] -= (newNumber(digit)*y)
    if ix < x.limbs.high:
      # carry a digit down
      result[1].limbs.add x.limbs[ix+1]
    
    result[1].normalize
  result[0].normalize

func `div`*(x, y: number): number = divMod(x, y).d

func `mod`*(x, y: number): number = divMod(x, y).m

func `shr`*(x, y: number): number = 
  ## bitshift right
  result = x
  for i in one..y:
    result = result div newNumber(2'u8)

const chars = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i' ,'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I' ,'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

func toString*(x: number, base: range[1..62] = 10): string = 
  ## number -> string, bases 1..62
  if x == zero: return "0"
  if x.negative: return "-" & x.abs.toString
  var left = x
  while left > zero:
    let (d, m) = divMod(left, newNumber(base))
    #debugEcho (d, m), left
    result.add chars[m.limbs[0]]
    left = d
  result.reversed

func `$`*(x: number): string = x.toString

func newNumber*(num: string, base: range[1..62] = 10): number = 
  ## string, bases 1..62 -> number
  if num[0] == '-': return -newNumber(num[1..^1])
  result = zero
  var power = one
  for i in num.reversed:
    for _ in 1..i.ord - 48:
      result += power
    power *= newNumber(10'u8)

func `^`*(x, y: number): number = 
  result = one
  for i in one..y:
    result *= x

when isMainModule:
  # testing stuff here, dont mind me... 
  echo "starting"
  func prime(x: number): bool = 
    for i in newNumber(2)..<x:
      if x mod i == zero: return false
    return true
  
  iterator primes(lim: number): number = 
    var
      test = newNumber(2)
    while test < lim:
      if prime test: yield test
      inc test

  echo newNumber(10)