" NOTES:
" - all language regexps ported from https://github.com/jacktasia/dumb-jump/blob/master/dumb-jump.el

" ----------------------------------------------
" Languages definitions
"
" Prototype of lang map entry
"
" call add(s:definitions.lang, {
"       \"type": '',
"       \"regexp": '',
"       \"emacs_regexp": '',
"       \"spec_success": [],
"       \"spec_failed": [],
       \})

let s:definitions = {}

fu! lang_map#get_definitions(language) abort
  if !lang_map#lang_exists(a:language)
    return
  endif

  return s:definitions[a:language]
endfu

fu! lang_map#regexp_tests()
  let errors = []

  for lang in keys(s:definitions)
    for entry in s:definitions[lang]
      let re = entry["regexp"]

      if len(re) > 0
        let test_re = substitute(re, 'KEYWORD', '\\w\\+', 'g')

        for spec_string in entry["spec_success"]
          if !(spec_string =~ test_re)
            call add(errors, "FAILED " . lang  . ": " . spec_string)
            " call s:log("FAILED: " . spec_string)
          endif
        endfor
      endif
    endfor
  endfor

  return errors
endfu

fu! lang_map#lang_exists(language) abort
  return has_key(s:definitions, a:language)
endfu

" Ruby
let s:definitions.ruby = []

call add(s:definitions.ruby, {
      \"type": "variable",
      \"regexp": '^\s*\(\(\w\+[.]\)*\w\+,\s*\)*KEYWORD\(,\s*\(\w\+[.]\)*\w\+\)*\s*=\([^=>~]\|$\)',
      \"emacs_regexp": '^\\s*((\\w+[.])*\\w+,\\s*)*JJJ(,\\s*(\\w+[.])*\\w+)*\\s*=([^=>~]|$)',
      \"spec_success": ["test = 1234", "self.foo, test, bar = args"],
      \"spec_failed": ["if test == 1234", "foo_test = 1234"],
      \})

call add(s:definitions.ruby, {
      \"type": "function",
      \"regexp": '\(^\|[^\w.]\)\(\(private\|public\|protected\)\s\+\)\?def\s\+\(\w\+\(::\|[.]\)\)*KEYWORD\($\|[^\w\|:]\)',
      \"emacs_regexp": '(^|[^\\w.])((private|public|protected)\\s+)?def\\s+(\\w+(::|[.]))*JJJ($|[^\\w|:])',
      \"spec_success": [ "def test(foo)", "def test()", "def test foo", "def test; end" ,
        \"def self.test()", "def MODULE::test()", "private def test" ],
      \"spec_failed": ["def test_foo"]
      \})

call add(s:definitions.ruby, {
      \"type": "function",
      \"regexp": '\(^\|\W\)define\(_singleton\|_instance\)\?_method\(\s\|[(]\)\s*:KEYWORD\($\|[^\w\|:]\)',
      \"emacs_regexp": '(^|\\W)define(_singleton|_instance)?_method(\\s|[(])\\s*:JJJ($|[^\\w|:])',
      \"spec_success": [ "define_method(:test, &body)", "mod.define_instance_method(:test) { body }" ],
      \"spec_failed": [],
      \})

call add(s:definitions.ruby, {
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

call add(s:definitions.ruby, {
      \"type": "type",
      \"regexp": '\(^\|[^\w.]\)class\s\+\(\w*::\)*KEYWORD\($\|[^\w|:]\)',
      \"emacs_regexp": '(^|[^\\w.])class\\s+(\\w*::)*JJJ($|[^\\w|:])',
      \"spec_success": [ "class test", "class Foo::test" ],
      \"spec_failed": [],
      \})

call add(s:definitions.ruby, {
      \"type": "type",
      \"regexp": '\(^\|[^\w.]\)class\s\+\(\w*::\)*KEYWORD\($\|[^\w\|:]\)',
      \"emacs_regexp": '(^|[^\\w.])class\\s+(\\w*::)*JJJ($|[^\\w|:])',
      \"spec_success": [ "class test", "class Foo::test" ],
      \"spec_failed": [],
      \})

call add(s:definitions.ruby, {
      \"type": "type",
      \"regexp": '\(^\|[^\w.]\)module\s\+\(\w*::\)*KEYWORD\($\|[^\w\|:]\)',
      \"emacs_regexp": '(^|[^\\w.])module\\s+(\\w*::)*JJJ($|[^\\w|:])',
      \"spec_success": [ "module test", "module Foo::test" ],
      \"spec_failed": [],
      \})

" Elixir
let s:definitions.elixir = []

call add(s:definitions.elixir, {
      \"type": "function",
      \"regexp": '\<def\(p\)\?\s\+KEYWORD\s*[ ,\\\(]',
      \"emacs_regexp": '\\bdef(p)?\\s+JJJ\\s*[ ,\\\(]',
      \"spec_success": ['def test do', 'def test, do:', 'def test() do', 'def test(), do:', 'def test(foo, bar) do', 'def test(foo, bar), do:', 'defp test do', 'defp test(), do:'],
      \"spec_failed": [],
      \})

call add(s:definitions.elixir, {
      \"type": "variable",
      \"regexp": '\s*KEYWORD\s*=[^=\\n]\+',
      \"emacs_regexp": '\\s*JJJ\\s*=[^=\\n]+',
      \"spec_success": ['test = 1234'],
      \"spec_failed": ['if test == 1234'],
      \})


call add(s:definitions.elixir, {
      \"type": "module",
      \"regexp": 'defmodule\s\+\(\w\+\.\)*KEYWORD\s\+',
      \"emacs_regexp": 'defmodule\\s+(\\w+\\.)*JJJ\\s+',
      \"spec_success": ['defmodule test do', 'defmodule Foo.Bar.test do'],
      \"spec_failed": [],
      \})

call add(s:definitions.elixir, {
      \"type": "module",
      \"regexp": 'defprotocol\s\+\(\w\+\.\)*KEYWORD\s\+',
      \"emacs_regexp": 'defprotocol\\s+(\\w+\\.)*JJJ\\s+',
      \"spec_success": ['defprotocol test do', 'defprotocol Foo.Bar.test do'],
      \"spec_failed": [],
      \})
