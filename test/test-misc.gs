// Identifier

this prototype arguments
$hello-other $hello
@hello-other @hello
UserData LOCALDATA

/*
 * block comments
 */
let mutable foo-bar = 100
foo-bar := 400
console.log foo-bar

// Comment in regex {{{
let foo = r"""
  # comments
"""
//}}}

// String
// auto camelCase
\name
[\some-key]
// interpolate
"some $foo-bar $(120 |> bar)"
// escape
'\012123 \x1f666 \u10de666 \0 \n \u{10dede}666'
// heredoc
"""
some $foo-bar $(f >> g)\tother
new line
"""
'''
no $x, no interpolate
new line\n
'''

// Regex
r"""
\b(abc|def)\b$special
# blahblahblah
"""g
r'\n'm

// Array
[1 to 5 by -2]
[0 to Infinity]
let items =
  * "appple" & " juice"
  * "banana"
  * "cherries"
  * id: 0
    name: "Dog"

array[* % foo-bar]
array[* + 100000]
"$(array[* + 0x1084])"

// Custom Interpolation
let str_arr = %"<h1>$title</h1>"
let str_arr2 = %"""
<ul class="$ul-class">
  <li></li>
</ul>
"""

// Function
let foo(name = "bar")
  "foo-$name"

// Spread
let hello(...names)
  "Hello, $(names.join ', ')"
f(0, ...f(...[0 to 10], 2), 3)

// Map
let map = %{
  [foo]: 1
}

// Set
let set = %[ foo-bar, 12 ]

// Object
some:$other:
  deeper:
    "199"
let child = { extends parent
  value: 42
}
let obj =
  foo:
    bar: 100
  foo:baz: 200
  "o_$i": "ooo"
  [1 + 2]: 'abc'
  'abc': [1,2,3]
// getter/setter
let obj =
  _x: @some
  @some: 123
  $foo: 123
  get x: #-> @_x
  property y:
    writable: true
  some-some: @x
  some: {x:x,y:y}
obj := 100

// Control
if foo
  "Bar"
else unless bar
  "Baz"
else if baz
  "Foo"
else
  "Oof"

until i >= 10
  i += 1

switch some
case 0, 1, 2
  "some"
case 3, 4, 5
  "other"
default
  "none"

try
  foo()
catch e as MyError
  i-have-to-handle-this(e)
catch e
  wtf()
else
  bar()
finally
  kick-foo()

// Loop
while i < 10, i += 1
  console.log i

for i in 0 til 10
  console. log i

for v, i, l in ["One", "Two", "Three"]
  console.log "No.$i of $l: $v"

for v in arr by -1

for k, v of some-object

let squares = for value in 0 to 10; value ^ 2

let all-good = for every item in array; item.is-good()
let all-good = while filter item in array

label! outer for v, idx from some-iter
  for v in arr
    if idx > 5
      break
    else
      continue outer

// iterator
let some-iter(a = 1)*
  yield (a + 1) / 2

// Class
class Animal
  def constructor(@name) ->
  def eat() -> "$(@name) eats"
class Ape extends Animal
  def eat() -> super.eat() & " a banana"

// Async
async err, text <- fs.read-file "test.txt", "utf8"
throw? err
console.log text
let run(cb)
  async! cb, text <- fs.read-file "test", "utf8"
  cb null, text

// Promises
let make-promise = promise! #(foo)*
  let text = yield read-file(foo)
  return text.to-upper-case()

let promise = make-promise()
  .then(on-success, on-failure)

let node-promise-wrapper(foo as String)
  returning false
  let my-promise = promise!
    let node-p = to-promise! fs.read-file foo, "utf8"
    let text = yield node-p
    return text.to-upper-case()
  my-promise.then on-success, on-failure

// Type
let foo(x as String|Number, point as {x: Number, y: Number}) -> "abc"
// generic type
let x as Function<Number> = f()
class MyClass<T>
  def constructor(@value as T) ->
let my-str-obj = MyClass<String>("hello")

let x as ( > Number) = f()
let y = x() + x()

// op2func
let sq = (^ 2)
let get-length = (.length)
