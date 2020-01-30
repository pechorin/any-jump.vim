" POINTS:
" - async load of additional searches
"   start async requests after some timeout of main rg request

" TODO:
" - [ ] add "save search" button
" - [ ] add save jumps lists inside popup window
" - [ ] add grouping for results?
" - [ ] add cache
" - [ ] add back commands
" - [ ] optimize regexps processing (do most job once)

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
" Render buffer
" ----------------------------------------------
let s:RenderBuffer = {}

" Produce new Render Buffer
"
" abstract: structure of internal render representation
"
" buffer = { items: [] }
" line   = [{ type, strat_col, finish_col, text, hl_group }, { ... }, ...]
"
" add(buffer, line)
"

let s:RenderBuffer.MethodsList = [
      \'RenderLine', 'AddLine', 'CreateItem',
      \'len', 'GetItemByPos',
      \'HandleClickEvent',
      \]

function! s:RenderBuffer.New(buf_id)
  let object = { "items": [], "buf_id": a:buf_id }

  for method in self.MethodsList
    let object[method] = s:RenderBuffer[method]
  endfor

  return object
endfunction

function! s:RenderBuffer.len() dict
  return len(self.items)
endfunction

function! s:RenderBuffer.RenderLine(items, current_len) dict
  for item in a:items
    call appendbufline(self.buf_id, a:current_len, "\t" . item.text)

    if len(item.hl_group) > 0
      " TODO add namespace instead of anon namespace?
      call nvim_buf_add_highlight(
            \self.buf_id,
            \-1,
            \item.hl_group,
            \a:current_len,
            \item.start_col,
            \item.end_col)
    endif
  endfor
endfunction

function! s:RenderBuffer.AddLine(items) dict
  if type(a:items) == v:t_list
    let current_len = self.len()

    call self.RenderLine(a:items, current_len)
    call add(self.items, a:items)

    return v:true
  else
    echoe "array required, got invalid type: " . string(a:items)

    return v:false
  endif
endfunction

" type:
"   'text' / 'link' / 'button' / 'preview_text'
function! s:RenderBuffer.CreateItem(type, text, start_col, end_col, hl_group) dict
  let item = {
        \"type":      a:type,
        \"text":      a:text,
        \"start_col": a:start_col,
        \"end_col":   a:end_col,
        \"hl_group":  a:hl_group,
        \}
  return item
endfunction

function! s:RenderBuffer.GetItemByPos(line_number, column) dict
  let line   = self.items[a:line_number - 1]

  for item in line
    if item.start_col <= a:column && (item.end_col >= a:column || item.end_col == -1 )
      return item
    endif
  endfor

  return
endfunction

function! s:RenderBuffer.HandleClickEvent(line_number, column, text) dict
  let ln   = self.items[a:line_number - 1]
  let item = self.GetItemByPos(a:line_number, a:column)

  if type(item) == v:t_dict
    echo "item -> " . string(item)
  endif
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

function! s:create_window(grep_results)
  if len(a:grep_results) == 0
    return 0
  endif

  " creates a scratch, unlisted, new, empty, unnamed buffer
  " to be used in the floating window
  let buf = nvim_create_buf(v:false, v:true)

  " nvim_buf_set_keymap(buf, 'n' ...)
  call nvim_buf_set_option(buf, 'filetype',  'any-jump')

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

  let b:grep_results = a:grep_results

  let b:render = s:RenderBuffer.New(buf)

  call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])

  call b:render.AddLine([ b:render.CreateItem("text", "Definitions", 0, -1, "Comment") ])
  call b:render.AddLine([ b:render.CreateItem("text", "-----------", 0, -1, "Comment") ])

  call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])

  " draw grep results
  for gr in a:grep_results
    let text = gr.text . ' (path:' .  gr.path .  ":" . gr.line_number . ")"

    call b:render.AddLine([ b:render.CreateItem("link", text, 0, -1, "Statement") ])
  endfor

  " call cursor(cursor_ln, 2)

  call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])
  call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])

  call b:render.AddLine([ b:render.CreateItem("text", "Help", 0, -1, "Comment") ])
  call b:render.AddLine([ b:render.CreateItem("text", "----", 0, -1, "Comment") ])

  call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])
  call b:render.AddLine([ b:render.CreateItem("text", "[o] open file   [p] preview file   [j] open best match", 0, -1, "Identifier") ])
  call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])

  call b:render.AddLine([ b:render.CreateItem("button", "[u] + search usages", 0, -1, "Identifier") ])
  call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])

  call b:render.AddLine([ b:render.CreateItem("button", "[f] + search file names", 0, -1, "Identifier") ])


  call b:render.AddLine([ b:render.CreateItem("button", "[c] + search cross projects", 0, -1, "Identifier") ])
  call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])

  call b:render.AddLine([ b:render.CreateItem("button", "[s] save search   [S] clean search   [N] next saved   [P] previous saved", 0, -1, "Identifier") ])
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
    call s:log('no results found for ' . keyword)
    return
  endif

  " echo "resuts count -> " . len(grep_results)
  " echo "first result -> " . string(grep_results[0])

  call s:create_window(grep_results)
endfunction

function! s:init()
  call s:run_tests()
endfunction

function! g:AnyJumpHandleOpen()
  if type(b:render) != v:t_dict
    return
  endif

  let line_number = line('.')
  let column      = col('.')
  let text        = getline(line_number)

  call b:render.HandleClickEvent(line_number, column, text)
endfunction

" Commands
command! AnyJumpToggleDebug call s:toggle_debug()
command! AnyJump call s:jump()

" Bindings
au FileType any-jump nnoremap <buffer> o :call g:AnyJumpHandleOpen()<cr>

call s:init()
