" POINTS:
" - async load of additional searches
"   start async requests after some timeout of main rg request

" NOTES:
" - all language regexps ported from https://github.com/jacktasia/dumb-jump/blob/master/dumb-jump.el
" - async guide: https://andrewvos.com/writing-async-jobs-in-vim-8/

let g:smart_jump_loaded = 1

" ----------------------------------------------
" Languages definitions
"
" Prototype of lang map entry
"
" call add(s:lang_map.lang, {
"       \"type": '',
"       \"regexp": '',
"       \"emacs_regexp": '',
"       \"spec_success": [],
"       \"spec_failed": [],
"       \})

let s:lang_map = {}

" Ruby
let s:lang_map.ruby = []

call add(s:lang_map.ruby, {
      \"type": "variable",
      \"regexp": '^\s*\(\(\w\+[.]\)*\w\+,\s*\)*KEYWORD\(,\s*\(\w\+[.]\)*\w\+\)*\s*=\([^=>~]\|$\)',
      \"emacs_regexp": '^\\s*((\\w+[.])*\\w+,\\s*)*JJJ(,\\s*(\\w+[.])*\\w+)*\\s*=([^=>~]|$)',
      \"spec_success": ["test = 1234", "self.foo, test, bar = args"],
      \"spec_failed": ["if test == 1234", "foo_test = 1234"],
      \})

call add(s:lang_map.ruby, {
      \"type": "function",
      \"regexp": '\(^\|[^\w.]\)\(\(private\|public\|protected\)\s\+\)\?def\s\+\(\w\+\(::\|[.]\)\)*KEYWORD\($\|[^\w\|:]\)',
      \"emacs_regexp": '(^|[^\\w.])((private|public|protected)\\s+)?def\\s+(\\w+(::|[.]))*JJJ($|[^\\w|:])',
      \"spec_success": [ "def test(foo)", "def test()", "def test foo", "def test; end" ,
        \"def self.test()", "def MODULE::test()", "private def test" ],
      \"spec_failed": ["def test_foo"]
      \})

call add(s:lang_map.ruby, {
      \"type": "function",
      \"regexp": '\(^\|\W\)define\(_singleton\|_instance\)\?_method\(\s\|[(]\)\s*:KEYWORD\($\|[^\w\|:]\)',
      \"emacs_regexp": '(^|\\W)define(_singleton|_instance)?_method(\\s|[(])\\s*:JJJ($|[^\\w|:])',
      \"spec_success": [ "define_method(:test, &body)", "mod.define_instance_method(:test) { body }" ],
      \"spec_failed": [],
      \})

call add(s:lang_map.ruby, {
      \"type": "function",
      \"regexp": '\(^\|\W\)alias\(_method\)\?\W\+KEYWORD\(\W\|$\)',
      \"emacs_regexp": '(^|\\W)alias(_method)?\\W+JJJ(\\W|$)',
      \"spec_success": [ "alias test some_method",
                        \"alias_method :test, :some_method",
                        \"alias_method 'test' 'some_method'",
                        \"some_class.send(:alias_method, :test, :some_method)" ],
      \"spec_failed": ["alias some_method test",
                        \"alias_method :some_method, :test",
                        \"alias test_foo test"],
      \})

call add(s:lang_map.ruby, {
      \"type": "type",
      \"regexp": '\(^\|[^\w.]\)class\s\+\(\w*::\)*KEYWORD\($\|[^\w|:]\)',
      \"emacs_regexp": '(^|[^\\w.])class\\s+(\\w*::)*JJJ($|[^\\w|:])',
      \"spec_success": [ "class test", "class Foo::test" ],
      \"spec_failed": [],
      \})

call add(s:lang_map.ruby, {
      \"type": "type",
      \"regexp": '\(^\|[^\w.\])class\s\+\(\w*::\)*KEYWORD\($\|[^\w\|:]\)',
      \"emacs_regexp": '(^|[^\\w.])class\\s+(\\w*::)*JJJ($|[^\\w|:])',
      \"spec_success": [ "class test", "class Foo::test" ],
      \"spec_failed": [],
      \})

call add(s:lang_map.ruby, {
      \"type": "type",
      \"regexp": '\(^\|[^\w.]\)module\s\+\(\w*::\)*KEYWORD\($\|[^\w\|:]\)',
      \"emacs_regexp": '(^|[^\\w.])module\\s+(\\w*::)*JJJ($|[^\\w|:])',
      \"spec_success": [ "module test", "module Foo::test" ],
      \"spec_failed": [],
      \})

" ----------------------------------------------
" Service functions

let s:debug = 1

function! g:SmartJumpDebug()
  if s:debug == 0
    let s:debug = 1
  else
    let s:debug = 0
  endif
endfunction

function! s:log(message)
  if s:debug == 1
    echo "[smart-jump] " . a:message
  endif
endfunction

function! g:SmartJumpTests()
  call s:regexp_tests()
  call s:log("Tests finished")
endfunction

function! s:regexp_tests()
  for lang in keys(s:lang_map)
    for entry in s:lang_map[lang]
      let re = entry["regexp"]

      if len(re) > 0
        let test_re = substitute(re, 'KEYWORD', '\\w\\+', 'g')

        for spec_string in entry["spec_success"]
          if !(spec_string =~ test_re)
            call s:log("FAILED: " . spec_string)
          endif
        endfor
      endif
    endfor
  endfor
endfunction

" ----------------------------------------------
" Functions

function! g:Current_filetype_lang_map()
  let ft = &l:filetype

  if ft
    return s:langmap[ft]
  else
    echo "not found map definition for " . ft
    return 0
  endif
endfunction
