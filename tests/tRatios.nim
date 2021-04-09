import unittest, apm, rationals

test "Fractional Addition test":
  for i in -1000..1000:
    for j in 1000..1000:
      if i == 0 or j == 0:continue
      let
        home = i.newNumber // j.newNumber
        away = i // j
      assert $(home+home.reciprocal) == $(away+away.reciprocal)

test "Fractional Subtraction test":
  for i in -1000..1000:
    for j in 1000..1000:
      if i == 0 or j == 0:continue
      let
        home = i.newNumber // j.newNumber
        away = i // j
      assert $(home-home.reciprocal) == $(away-away.reciprocal)

test "Fractional Multiplacation test":
  for i in -1000..1000:
    for j in 1000..1000:
      if i == 0 or j == 0:continue
      let
        home = i.newNumber // j.newNumber
        away = i // j
      assert $(home*home.reciprocal) == $(away*away.reciprocal)

test "Fractional Division test":
  for i in -1000..1000:
    for j in 1000..1000:
      if i == 0 or j == 0:continue
      let
        home = i.newNumber // j.newNumber
        away = i // j
      assert $(home/home.reciprocal) == $(away/away.reciprocal)