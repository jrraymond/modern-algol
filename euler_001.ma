/* list all natural numbers that are multiples of 3 or 5 below 1000 */


p001 = \lo:num.\hi:num.fix p:(num->num)*num .
  if i > hi
  then acc 
  else if i%15!=0 && i%5==0 && i%3==0
       then (fst p) (i+1) (snd p + i)
       else (fst p) (i+1) (snd p)

main = \x:num.p001 1 x
