// vanilla js
abc instanceof
typeof abc
delete abc

// basic
1.00 + 2.0_000_e+10_ms + 1.000
1 - 2.0_000000_ms + 0x1050_1bff
0x1 % -0o2
1 %% 2
abc + bac
abc - bac
abc * bac
abc * // wrong
abc / bac
abc % bac
abc & bac
abc \ bac
abc ^ bac
abc ? bac
abc > bac
abc < bac
     -bac
     +bac

// assign
abc ?=          bac
abc :=          bac
abc min=        bac
abc max=        bac
abc ownsor=     bac
abc and=        bac
abc or=         bac
abc bitand=     bac
abc bitor=      bac
abc bitxor=     bac
abc bitnot=     bac
abc bitlshift=  bac
abc bitrshift=  bac
abc biturshift= bac

// compare
abc >= bac
abc >= // wrong
abc <= bac
abc <=> bac
abc == +bac
abc != -bac
abc ~= bac
abc !~= bac
abc is bac
abc isnt bac
// wrong
abc || bac
abc && bac

// bool
abc and bac
abc or bac
not abc
abc?
f?()

// bit-op
abc bitand     bac
abc bitor      bac
abc bitxor     bac
abc bitnot     bac
abc bitlshift  bac
abc bitrshift  bac
abc biturshift bac
(abc biturshift bac)

// inc/dec
--abc
++abc
post-dec! abc
post-inc! abc
abc +=- bac
abc -=+ bac

// ranges
x to y
x til y
[1, 2, 3] by 1
x to y by 1
x til y by 1

// functional programming
abc >> bac
111 << bac // wrong
bac >> 111 // wrong
abc << bac
abc >>> bac
abc <<< bac
abc <>< bac // wrong
abc <| 111
111 <| bac // wrong
111 |> bac
abc |> 111 // wrong

// is family
is-array!     abc
is-boolean!   abc
is-function!  abc
is-null!      abc
is-number!    abc
is-object!    abc
is-string!    abc
is-undefined! abc
is-void!      abc

// ! family
typeof!          abc
allkeys!         abc
keys!            abc
label!           abc
map!             abc
mutate-function! abc
set!             abc

// ? family
throw? abc
return? abc
let you = value?.which.might?.not.exist

// other
abc in bac
abc in [1,2,3]
abc not ownskey bac
abc haskey bac
abc instanceofsome bac
abc not instanceof bac
foo![key]
foo!.key
f@ obj
f-oo@(obj)
some@.f
some.f
other.f
some a, #
  foo()

@ = 100
let [x, ...y] = [1, 2, 3, 4]
let [a, {b, c: [d]}] = get-data()

let f() -> abc
async abc <- some

// assign
let mutable a = b
a := 123
