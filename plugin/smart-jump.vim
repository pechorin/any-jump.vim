" POINTS:
" - async load of additional searches
"   start async requests after some timeout of main rg request

" NOTES:
" - all language regexps ported from https://github.com/jacktasia/dumb-jump/blob/master/dumb-jump.el
" - async guide: https://andrewvos.com/writing-async-jobs-in-vim-8/

let g:any_jump_loaded = 1

" THINK:
"
" in line:
" "MyNamespace::MyClass"
"
" then cursor is on MyClass word
"
" 'word' - will match MyClass
" 'full' - will match MyNamespace::MyClass
let g:any_jump_keyword_match_cursor_mode = 'word'

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
      \"regexp": '\(^\|[^\w.]\)class\s\+\(\w*::\)*KEYWORD\($\|[^\w\|:]\)',
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
" ----------------------------------------------

let s:debug = 1

function! s:toggle_debug()
  if s:debug == 0
    let s:debug = 1
  else
    let s:debug = 0
  endif

  echo "debug enabled: " . s:debug
endfunction

function! s:log(message)
  echo "[smart-jump] " . a:message
endfunction

function! s:log_debug(message)
  if s:debug == 1
    echo "[smart-jump] " . a:message
  endif
endfunction

function! s:regexp_tests()
  let errors = []

  for lang in keys(s:lang_map)
    for entry in s:lang_map[lang]
      let re = entry["regexp"]

      if len(re) > 0
        let test_re = substitute(re, 'KEYWORD', '\\w\\+', 'g')

        for spec_string in entry["spec_success"]
          if !(spec_string =~ test_re)
            call add(errors, "FAILED: " . spec_string)
            " call s:log("FAILED: " . spec_string)
          endif
        endfor
      endif
    endfor
  endfor

  return errors
endfunction

function! s:run_tests()
  let errors = []
  let errors += s:regexp_tests()

  if len(errors) > 0
    for error in errors
      echo error
    endfor
  endif

  call s:log("Tests finished")
endfunction

" ----------------------------------------------
" Functions
" ----------------------------------------------

function! s:current_filetype_lang_map()
  let ft = &l:filetype
  return get(s:lang_map, ft)
endfunction

function! s:new_grep_result()
  let dict = { "line_number": 0, "path": 0, "text": 0 }
  return dict
endfunction

function! s:search_rg(lang, keyword)
  let patterns = []

  for rule in s:lang_map[a:lang]
    " insert real keyword insted of placeholder
    let regexp = substitute(rule.regexp, "KEYWORD", a:keyword, "g")

    " remove vim escapings
    let regexp = substitute(regexp, '\\(', '(', 'g')
    let regexp = substitute(regexp, '\\)', ')', 'g')
    let regexp = substitute(regexp, '\\+', '+', 'g')
    let regexp = substitute(regexp, '\\|', '|', 'g')
    let regexp = substitute(regexp, '\\?', '?', 'g')

    call add(patterns, regexp)
  endfor

  let regexp = map(patterns, { _, pattern -> '(' . pattern . ')' })
  let regexp = join(regexp, '|')
  let regexp = "'(" . regexp . ")'"

  let cmd          = "rg -n --json -t " . a:lang . ' ' . regexp
  let raw_results  = system(cmd)
  let grep_results = []

  if len(raw_results) > 0
    let matches = []

    for res in split(raw_results, "\n")
      let match = json_decode(res)
      call add(matches, match)
    endfor

    for match in matches
      if get(match, 'type') == 'match'
        let data = get(match, 'data')

        if type(data) == v:t_dict
          let text = data.lines.text
          let text = substitute(text, '^\s*', '', 'g')
          let text = substitute(text, '\n', '', 'g')

          let grep_result             = s:new_grep_result()
          let grep_result.line_number = data.line_number
          let grep_result.path        = data.path.text
          let grep_result.text        = text

          call add(grep_results, grep_result)
          " call s:log_debug(string(grep_result))
        endif
      end
    endfor
  endif

  return grep_results
endfunction

function! s:draw_results(grep_results)
  if len(a:grep_results) == 0
    return 0
  endif

  " creates a scratch, unlisted, new, empty, unnamed buffer
  " to be used in the floating window
  let buf = nvim_create_buf(v:false, v:true)

  " 90% of the height
  let height = float2nr(&lines * 0.7)
  " 60% of the height
  let width = float2nr(&columns * 0.5)
  " horizontal position (centralized)
  let horizontal = float2nr((&columns - width) / 2)
  " vertical position (one line down of the top)
  let vertical = 2

  let opts = {
        \ 'relative': 'editor',
        \ 'row': vertical,
        \ 'col': horizontal,
        \ 'width': width,
        \ 'height': height
        \ }

  " open the new window, floating, and enter to it
  call nvim_open_win(buf, v:true, opts)

  let cl = 0

  function! Append(text) closure
    call appendbufline(buf, cl, "\t" . a:text)
    let cl += 1
  endfunction

  let cl += 1
  call Append("Definitions")
  call nvim_buf_add_highlight(buf, -1, 'Comment', cl - 1, 0, -1)

  call Append("-----------")
  call nvim_buf_add_highlight(buf, -1, 'Comment', cl - 1, 0, -1)
  call Append("")

  let cursor_ln = cl + 1 " line number of first match

  " draw grep results
  for gr in a:grep_results
    let text = "- " . gr.text . ' (' .  gr.path .  ":" . gr.line_number . ")"

    call Append(text)
    call nvim_buf_add_highlight(buf, -1, 'Statement', cl - 1, 0, -1)
  endfor

  call cursor(cursor_ln, 2)

  call Append("")
  call Append("")

  " draw help
  call Append("Help & Controls")
  call nvim_buf_add_highlight(buf, -1, 'Comment', cl - 1, 0, -1)

  call Append("---------------")
  call nvim_buf_add_highlight(buf, -1, 'Comment', cl - 1, 0, -1)
  call Append("")
  call Append("[o] open file   [p] preview file   [j] open best match")
  call nvim_buf_add_highlight(buf, -1, 'Identifier', cl - 1, 0, -1)
  call Append("")
  call Append("[u] + search usages")
  call nvim_buf_add_highlight(buf, -1, 'Identifier', cl - 1, 0, -1)
  call Append("[f] + search file names")
  call nvim_buf_add_highlight(buf, -1, 'Identifier', cl - 1, 0, -1)
  call Append("[c] + search cross projects")
  call nvim_buf_add_highlight(buf, -1, 'Identifier', cl - 1, 0, -1)

endfunction

function! s:jump()
  " check current language
  if (type(s:current_filetype_lang_map()) == v:t_list) == v:false
    call s:log("not found map definition for filetype " . string(&l:filetype))
    return
  endif

  " fetch lookup keyword
  let keyword  = ''
  let cur_mode = mode()

  if cur_mode == 'n'
    let keyword = expand('<cword>')
  else
    " THINK: implement visual mode selection?
    " https://stackoverflow.com/a/6271254/190454
    call s:log_debug("not implemented for mode " . cur_mode)
    return
  endif

  if len(keyword) == 0
    return
  endif

  let grep_results = s:search_rg(&l:filetype, keyword)

  if len(grep_results) == 0
    call s:log('No results foubd for ' . keyword)
    return
  endif

  " echo "resuts count -> " . len(grep_results)
  " echo "first result -> " . string(grep_results[0])

  call s:draw_results(grep_results)
endfunction

function! s:init()
  call s:run_tests()
endfunction

command! AnyJumpToggleDebug call s:toggle_debug()
command! AnyJump call s:jump()

call s:init()
