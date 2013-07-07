// Should be an error
function := 42
var := 42
let __lt = 100

// Shouldn't be an error
abc.with := 42
abs.as := 42
function: 42
__lt: hello
var: 42
class: 42

// Keywords shouldn't be highlighted
abc.function
abc.do
abc.break
abc.true

abc::function
abc::do
abc::break
abc::true

abc:: function
abc:: function-call
abc. do

// Numbers should be highlighted
def.42
def .42
def::42
some-home::111
$abc:: 100
@abc::    100

// prelude words
__lt __slice __is-array

// not like coffeescript
let a = 10; foo(a)
