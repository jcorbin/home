" Language:    GorillaScript
" Maintainer:  "UnCO" Lin <undercooled _aT_ lavabit _dOt_ com>
" URL:         http://github.com/unc0/vim-gorilla-script
" License:     WTFPL

" Bail if our syntax is already loaded.
if exists('b:current_syntax') && b:current_syntax == 'gorilla'
  finish
endif

" Highlight long strings.
syn sync minlines=100

" GorillaScript identifiers can have dollar signs.
setlocal isident+=$
setlocal iskeyword+=-,!

" Keywords {{{
syn keyword gorillaStatement      break continue return yield
syn keyword gorillaRepeat         for while contained
syn keyword gorillaRepeat         until
syn match   gorillaRepeatFunc     /\%(for\|while\)\s\+\%(every\|first\|filter\|reduce\|some\)\?/ display contains=gorillaRepeat
syn keyword gorillaConditional    if else unless switch then
syn keyword gorillaLabel          case default
syn keyword gorillaException      catch finally try Error EvalError RangeError ReferenceError SyntaxError TypeError URIError
syn match   gorillaException      /\<throw\>/ display

syn keyword gorillaClassKeyword   new class haskey
syn match   gorillaClassKeyword   /\s\+\<\zs\%\(def\|super\)\>/ display
syn match   gorillaClassKeyword   /\%(get\|set\|property\|configurable\|writable\)\ze\%(\s*\S\+\)\?:/ display
syn keyword gorillaSpecialKeyword require require! async async!
syn keyword gorillaSpecialKeyword import export asyncif asyncfor asyncunless asyncuntil asyncwhile returnif returning returnunless
syn keyword gorillaSpecialMacro   mutable macro const static extends
syn keyword gorillaKeyword        do of let enum namespace package
syn keyword gorillaBoolean        true false
syn keyword gorillaNull           null undefined void
syn keyword gorillaMessage        confirm prompt status
syn keyword gorillaSpecialObject  console alert next constructor
syn keyword gorillaGlobal         GLOBAL Array Boolean Date Function Math Number Object RegExp String clear-interval set-interval clear-timeout set-timeout decode-URI decode-URI-component encode-URI encode-URI-component escape unescape has-own-property is-finite is-NaN is-prototype-of parse-float parse-int property-is-enumerable to-locale-string to-string value-of
"}}}

" Vanilla JS Operators {{{
syn keyword gorillaOperator instanceof
syn match   gorillaOperator /\<typeof\>/ display
"}}}

" Extended Operators {{{
syn keyword gorillaExtendedOp    isnt in to til by instanceofsome not xor ownskey delete

syn match   gorillaExtendedOp    /\<is\>/ display
syn match   gorillaExtendedOp    /\<\%(and\|or\|min\|max\|bit\%(and\|or\|xor\|not\|lshift\|rshift\|urshift\)\)\>=\?/ display
syn keyword gorillaExtendedOp    typeof! allkeys! keys! label! map! mutate-function! set! post-dec! post-inc! is-array! is-boolean! is-function! is-null! is-number! is-object! is-string! is-undefined! is-void!
syn match   gorillaExtendedOp    /\<\%(throw\|return\)?/ display
syn keyword gorillaSpecialOp     as with from promise! to-promise!

syn match   gorillaExtendedOp    /\%([^ %=\^\<>*/+\-&?]\s*\)\@<=\%([\^\\*\/<>]\|%\{1,2}\|\%(!\~\|[!~]\)=\|==\|<=>\|>=\|<=\)\ze\%(\s*[^ %=\^\<>*/&?]\|\s\+[-+]\)/ display
" ?= := =
syn match   gorillaExtendedOp    /@\?[^ :=]*\s*\zs[?:]\?=/ display
" ?
syn match   gorillaExtendedOp    /\>\zs\s*?=\@!/ display
" & - string concat
syn match   gorillaExtendedOp    /&\ze\P/ display
" Pipes
syn match   gorillaExtendedOp    /\%(\I\i*\s*\zs<|\||>\ze\s*\I\i*\)/ display
"+ += - -=
syn match   gorillaExtendedOp    /\%(-\{1,2}\|+\{1,2}\)\ze\I\i*/ display
syn match   gorillaExtendedOp    /\%([^ -+]\s*\)\@<=[-+]=\?/ display
" :
syn match   gorillaExtendedOp    /:\%(\ze\s*\%(\S\+\)\|$\)/ display
" << >> <<< >>>
syn match   gorillaExtendedOp    /\I\i*\s*\zs\%(<<\|>>\)\ze\s*\I\i*/ display
syn match   gorillaExtendedOp    /[^<>]\s*\zs\%(<<<\|>>>\)/ display
" , ; ...
syn match   gorillaSpecialOp     /[,;]\|\%(\.\.\.\ze\S\)/ display
" .
syn match   gorillaSpecialOp     /\I\i*\zs!\.\ze\I\i*/ display
" #-> #()
syn match   gorillaSpecialOp     /#->/ display
syn match   gorillaSpecialOp     /#\ze(\|$/ display
" -> <-
syn match   gorillaSpecialOp     /\%(<-\|->\)\ze\%(\s*\S\|$\)/ display

syn match   gorillaAssign        /\I\i*\s*\ze\%(:\|:=\)[:=]\@!/ contains=@gorillaAllIdent,@gorillaNormalNumber,@gorillaBasicString,@gorillaInterpString display
syn match   gorillaDotAccess     /\.\s*\%(\i\+\|$\)/he=s+1 contains=gorillaIdent,@gorillaNormalNumber display
syn match   gorillaProtoAccess   /::\s*\i\+/he=s+2 contains=gorillaIdent,@gorillaNormalNumber display
"}}}

" Comments {{{
syn match    gorillaShebang     "^#!.*\(gjs-\)\?gorilla\>"
syn keyword  gorillaCommentTodo TODO FIXME XXX TBD WTF contained
syn match    gorillaLineComment "\/\/.*" contains=@Spell,gorillaCommentTodo
syn match    gorillaCommentSkip "^[ \t]*\*\($\|[ \t]\+\)"
syn region   gorillaComment     start="/\*" end="\*/" contains=@Spell,gorillaCommentTodo
"}}}

" Variables {{{
syn keyword gorillaSpecialVar   this prototype arguments
" A class-like name that starts with a capital letter
syn match   gorillaObject       /\<\u\w*\>/ display
" A constant-like name in SCREAMING_CAPS
syn match   gorillaConstant     /\<\u[A-Z0-9_]\+\>/ display
" An @-variable
syn match   gorillaSpecialIdent /@\<\%(\I\%(\i\|-\)*\)\?\>/ display
" An $-variable
syn match   gorillaSpecialIdent /\$\<\%(\I\%(\i\|-\)*\)\?\>/ display
" A variable name
syn match   gorillaIdent        /\<\I\%(\i*-\+\)\+\i*!\?\>/ display
syn cluster gorillaAllIdent contains=gorillaSpecialVar,gorillaObject,gorillaConstant,gorillaSpecialIdent,gorillaIdent
"}}}

" Numbers {{{
" A integer, including a leading plus or minus
syn match   gorillaNumber /+\?\<-\?\d[0-9_]*\%([eE][-+]\?\d[0-9_]*\)\?\%(_\+\w*\)\?\>/ display
" A hex, binary, or octal number
syn match   gorillaNumber /+\?\<-\?0[xX]\x[0-9a-fA-F_]*\>/ display
syn match   gorillaNumber /+\?\<-\?0[bB][01][01_]*\>/ display
syn match   gorillaNumber /+\?\<-\?-\?0[oO]\o[0-7_]*\>/ display
" A redix number
syn match   gorillaNumber /+\?\<-\?[1-3]\?[0-9][rR]\w\+\>/ display
" float
syn match   gorillaFloat  /+\?\<-\?\d[0-9_]*\.\d[0-9_]\+\%([eE][-+]\?\d[0-9_]*\)\?\%(_\+\w*\)\?\>/ display
" others
syn keyword gorillaNumber Infinity NaN
syn cluster gorillaNormalNumber contains=gorillaNumber,gorillaFloat
"}}}

" Strings {{{
syn match gorillaEscape /\\\d\d\d\|\\x\x\{2}\|\\u\x\{4}\|\\u{\x\{6}}\|\\[0-7bfrntv]/ contained display
" A non-interpolated string
syn cluster gorillaBasicString contains=@Spell,gorillaEscape
" Interpolate
syn region gorillaInterp matchgroup=gorillaInterpDelim start=/\$(/ end=/)/ contained contains=@gorillaAll
syn match gorillaInterpIdent /\$\h\%(\w\|-\)*/ contained
" An interpolated string
syn cluster gorillaInterpString contains=@gorillaBasicString,gorillaInterp,gorillaInterpIdent
" Regular strings
syn region gorillaString start=/%\?"/ skip=/\\\\\|\\"/ end=/"/ contains=@gorillaInterpString
syn region gorillaString start=/%\?'/ skip=/\\\\\|\\'/ end=/'/ contains=@gorillaBasicString
" Heredoc strings
syn region gorillaHereString start=/%\?"""/ end=/"""/ contains=@gorillaInterpString fold
syn region gorillaHereString start=/%\?'''/ end=/'''/ contains=@gorillaBasicString fold
" Special strings
syn match gorillaSpecialString /\\\<\%(\w\|-\)\+\>/ display
"}}}

" Regex {{{
" Regular expression
syn region gorillaRegex start=/r"/ end=/"[gimy]\{,4}/ oneline contains=@gorillaInterpString
syn region gorillaRegex start=/r'/ end=/'[gimy]\{,4}/ oneline contains=@gorillaBasicString
" A comment in a heregex
syn region gorillaHeregexComment start=/#/ end=/\ze\/\/\/\|$/ contained contains=@Spell,gorillaTodo
" Heredoc Regex
syn region gorillaHeregex start=/r"""/ end=/"""[gimy]\{,4}/ contains=@gorillaInterpString,gorillaHeregexComment fold
syn region gorillaHeregex start=/r'''/ end=/'''[gimy]\{,4}/ contains=@gorillaBasicString,gorillaHeregexComment fold
"}}}

" Containers {{{
syn region gorillaCurlies matchgroup=gorillaCurly start=/%\?{/ end=/}/ contains=@gorillaAll
syn region gorillaBrackets matchgroup=gorillaBracket start=/[%!]\?\[/ end=/\]/ contains=@gorillaAll
syn region gorillaParens matchgroup=gorillaParen start=/(/ end=/)\%(\*$\)\?/ contains=@gorillaAll
syn region gorillaLists matchgroup=gorillaList start=/^\s\+\*/ end=/$/ contains=@gorillaAll
" array negative indexing
syn match  gorillaNegIdxInner /.*\ze\]/ contained contains=@gorillaNormalNumber,@gorillaAllIdent
syn region gorillaNegIdxR matchgroup=gorillaNegIdx start=/\I\i*\[\*/ end=/\]/ contains=gorillaNegIdxInner
syn region gorillaGeneric matchgroup=gorillaGenericType start=/<\u\w*/ end=/>/ oneline contains=gorillaGlobal,gorillaObject
"}}}

" Errors {{{
" reserved words from javascript
syn match gorillaReservedError /\<\%(case\|default\|void\|with\|const\|let\|enum\|export\|import\|native\|package\|private\|protected\|public\|static\|function\|var\|implements\|interface\|volatile\|__proto__\)\>:\@!/ display
" reserved words from gorillascript's jsprelude
syn match gorillaReservedError /\<__\%(allkeys\|array\%(-t\|T\)o\%(-i\|I\)ter\|async\|async\%(-i\|I\)ter\|bind\|cmp\|compose\|create\|curry\|def\%(-p\|P\)rop\|floor\|freeze\|freeze\%(-f\|F\)unc\|generic\%(-f\|F\)unc\|get\%(-i\|I\)nstanceof\|import\|in\|index\%(-o\|O\)f\%(-i\|I\)dentical\|instanceofsome\|int\|is\|is\%(-a\|A\)rray\|is\%(-o\|O\)bject\|iter\|keys\|log\|lt\|lte\|name\|new\|nonzero\|num\|once\|owns\|pow\|range\|slice\|slice\%(-s\|S\)tep\|sqrt\|step\|str\|strnum\|to\%(-a\|A\)rray\|typeof\|xor\)\>:\@!/ display
" === !==
syn match   gorillaExtendedOpError /===\|!==/ display
" !x
syn match   gorillaExtendedOpError /!\ze[^=~ [.(]/ display
" bitop
syn match   gorillaExtendedOpError /||\|&&/ display
"}}}

" All {{{
syn cluster gorillaAll contains=
\ gorillaStatement,gorillaRepeat,gorillaRepeatFunc,
\ gorillaConditional,gorillaLabel,gorillaException,
\ gorillaClassKeyword,gorillaSpecialKeyword,
\ gorillaSpecialMacro,gorillaKeyword,gorillaBoolean,
\ gorillaNull,gorillaMessage,gorillaSpecialObject,
\ gorillaGlobal,gorillaOperator,gorillaExtendedOp,
\ gorillaSpecialOp,gorillaAssign,gorillaDotAccess,
\ gorillaProtoAccess,gorillaLineComment,gorillaComment,
\ gorillaSpecialVar,gorillaObject,gorillaConstant,
\ gorillaSpecialIdent,gorillaIdent,gorillaNumber,
\ gorillaFloat,gorillaString,gorillaHereString,
\ gorillaSpecialString,gorillaRegex,gorillaHeregex,
\ gorillaCurlies,gorillaBrackets,gorillaParens,
\ gorillaLists,gorillaNegIdxR,gorillaGeneric,
\ gorillaReservedError,gorillaExtendedOpError,
\ gorillaSpaceError
"}}}

if version >= 508 || !exists("did_gorillascript_syntax_inited")
  if version < 508
    let did_gorillascript_syntax_inited = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
  HiLink gorillaStatement       Statement
  HiLink gorillaRepeat          Repeat
  HiLink gorillaRepeatFunc      Function
  HiLink gorillaLabel           gorillaConditional
  HiLink gorillaConditional     Conditional
  HiLink gorillaException       Exception
  HiLink gorillaClassKeyword    gorillaKeyword
  HiLink gorillaBoolKeyword     gorillaKeyword
  HiLink gorillaSpecialKeyword  gorillaKeyword
  HiLink gorillaKeyword         Keyword

  HiLink gorillaShebang         gorillaComment
  HiLink gorillaLineComment     gorillaComment
  HiLink gorillaHeregexComment  gorillaComment
  HiLink gorillaCommentTodo     Todo
  HiLink gorillaComment         Comment

  HiLink gorillaDotAccess       gorillaOperator
  HiLink gorillaProtoAccess     gorillaOperator
  HiLink gorillaExtendedOp      gorillaOperator
  HiLink gorillaOperator        Operator
  HiLink gorillaSpecialOp       SpecialChar

  HiLink gorillaBoolean         Boolean
  HiLink gorillaNull            Type
  HiLink gorillaMessage         Keyword
  HiLink gorillaSpecialMacro    Macro
  HiLink gorillaSpecialObject   Function
  HiLink gorillaGlobal          Type
  HiLink gorillaSpecialVar      Special
  HiLink gorillaSpecialIdent    Identifier
  HiLink gorillaAssign          Identifier
  HiLink gorillaIdent           PreProc
  HiLink gorillaObject          Structure
  HiLink gorillaConstant        Constant

  HiLink gorillaNumber          Number
  HiLink gorillaFloat           Float

  HiLink gorillaEscape          SpecialChar
  HiLink gorillaInterpDelim     PreProc
  HiLink gorillaInterpIdent     PreProc
  HiLink gorillaHereString      gorillaString
  HiLink gorillaSpecialString   gorillaString
  HiLink gorillaRegex           gorillaString
  HiLink gorillaHeregex         gorillaString
  HiLink gorillaString          String

  HiLink gorillaBracket         gorillaBlock
  HiLink gorillaCurly           gorillaBlock
  HiLink gorillaParen           gorillaBlock
  HiLink gorillaList            gorillaBlock
  HiLink gorillaNegIdx          gorillaBlock
  HiLink gorillaBlock           gorillaSpecialOp
  HiLink gorillaNegIdxInner     PreProc
  HiLink gorillaGenericType     Type

  HiLink gorillaReservedError   Error
  HiLink gorillaExtendedOpError Error
  " An error for trailing whitespace, as long as the line isn't just whitespace
  if exists("gorilla_trailing_space_error")
    syn match gorillaSpaceError /\S\@<=\s\+$/ display
    HiLink gorillaSpaceError Error
  endif

  delcommand HiLink
endif

if !exists('b:current_syntax')
  let b:current_syntax = 'gorilla'
endif
