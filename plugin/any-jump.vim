" POINTS:
" - async load of additional searches
"   start async requests after some timeout of main rg request

" TODO:
" - [ ] При не сохраненном файле вылетает ошибка на jump'е
" - [ ] AnyJumpFirst
" - [ ] add failed tests run & move test load to separate command
" - [ ] save winid, not bufid for correct focus change
" - [ ] add "save search" button
" - [ ] add save jumps lists inside popup window
" - [ ] add grouping for results?
" - [ ] add cache
" - [*] add back commands
" - [ ] optimize regexps processing (do most job once)
" - [ ] compact/full ui mode
" - [ ] hl keyword line in preview

" NOTES:
" - all language regexps ported from https://github.com/jacktasia/dumb-jump/blob/master/dumb-jump.el
" - async guide: https://andrewvos.com/writing-async-jobs-in-vim-8/

let g:any_jump_loaded = v:true

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

" available variants: 1/2
let g:any_jump_definitions_results_list_style = 1

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
       \})

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

" Elixir
let s:lang_map.elixir = []

call add(s:lang_map.elixir, {
      \"type": "function",
      \"regexp": '\<def\(p\)\?\s\+KEYWORD\s*[ ,\\\(]',
      \"emacs_regexp": '\\bdef(p)?\\s+JJJ\\s*[ ,\\\(]',
      \"spec_success": ['def test do', 'def test, do:', 'def test() do', 'def test(), do:', 'def test(foo, bar) do', 'def test(foo, bar), do:', 'defp test do', 'defp test(), do:'],
      \"spec_failed": [],
      \})

call add(s:lang_map.elixir, {
      \"type": "variable",
      \"regexp": '\s*KEYWORD\s*=[^=\\n]\+',
      \"emacs_regexp": '\\s*JJJ\\s*=[^=\\n]+',
      \"spec_success": ['test = 1234'],
      \"spec_failed": ['if test == 1234'],
      \})


call add(s:lang_map.elixir, {
      \"type": "module",
      \"regexp": 'defmodule\s\+\(\w\+\.\)*KEYWORD\s\+',
      \"emacs_regexp": 'defmodule\\s+(\\w+\\.)*JJJ\\s+',
      \"spec_success": ['defmodule test do', 'defmodule Foo.Bar.test do'],
      \"spec_failed": [],
      \})

call add(s:lang_map.elixir, {
      \"type": "module",
      \"regexp": 'defprotocol\s\+\(\w\+\.\)*KEYWORD\s\+',
      \"emacs_regexp": 'defprotocol\\s+(\\w+\\.)*JJJ\\s+',
      \"spec_success": ['defprotocol test do', 'defprotocol Foo.Bar.test do'],
      \"spec_failed": [],
      \})

" ----------------------------------------------
" Service functions
" ----------------------------------------------

let s:debug = 1

fu! s:toggle_debug()
  if s:debug == 0
    let s:debug = 1
  else
    let s:debug = 0
  endif

  echo "debug enabled: " . s:debug
endfu

fu! s:log(message)
  echo "[smart-jump] " . a:message
endfu

fu! s:log_debug(message)
  if s:debug == 1
    echo "[smart-jump] " . a:message
  endif
endfu

fu! s:regexp_tests()
  let errors = []

  for lang in keys(s:lang_map)
    for entry in s:lang_map[lang]
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

fu! s:run_tests()
  let errors = []
  let errors += s:regexp_tests()

  if len(errors) > 0
    for error in errors
      echo error
    endfor
  endif

  call s:log("Tests finished")
endfu

" ----------------------------------------------
" Render buffer definition
" ----------------------------------------------
let s:RenderBuffer = {} " prototype dict

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
      \'RenderLine',
      \'AddLine',
      \'AddLineAt',
      \'CreateItem',
      \'len',
      \'GetItemByPos',
      \'GetItemLineNumber',
      \]

fu! s:RenderBuffer.New(buf_id) abort
  let object = { "items": [], "buf_id": a:buf_id, "preview_opened": 0 }

  for method in self.MethodsList
    let object[method] = s:RenderBuffer[method]
  endfor

  return object
endfu

fu! s:RenderBuffer.len() dict abort
  return len(self.items)
endfu

fu! s:RenderBuffer.RenderLine(items, line) dict abort
  let base_prefix = "\t"
  let text        = base_prefix
  let hl_regions  = []

  for item in a:items
    let prefix = ""

    if item.start_col > 0
      let prefix = repeat(" ", item.start_col)
    endif

    let hl_from = item.start_col + len(text)
    let hl_to   = hl_from + len(prefix . item.text)
    let text    = text . prefix . item.text

    call add(hl_regions, [item.hl_group, hl_from, hl_to])
  endfor

  call appendbufline(self.buf_id, a:line, text)

  for region in hl_regions
    call nvim_buf_add_highlight(
          \self.buf_id,
          \-1,
          \region[0],
          \a:line,
          \region[1],
          \region[2])
  endfor
endfu

fu! s:RenderBuffer.AddLine(items) dict abort
  if type(a:items) == v:t_list
    let current_len = self.len()

    call self.RenderLine(a:items, current_len)
    call add(self.items, a:items)

    return v:true
  else
    echoe "array required, got invalid type: " . string(a:items)

    return v:false
  endif
endfu

fu! s:RenderBuffer.AddLineAt(items, line_number) dict abort
  if type(a:items) == v:t_list
    call self.RenderLine(a:items, a:line_number)
    call insert(self.items, a:items, a:line_number)

    return v:true
  else
    echoe "array required, got invalid type: " . string(a:items)

    return v:false
  endif
endfu

" type:
"   'text' / 'link' / 'button' / 'preview_text'
fu! s:RenderBuffer.CreateItem(type, text, start_col, end_col, hl_group, ...) dict abort
  let data = 0

  if a:0 > 0
    let data = a:1
  endif

  let item = {
        \"type":      a:type,
        \"text":      a:text,
        \"start_col": a:start_col,
        \"end_col":   a:end_col,
        \"hl_group":  a:hl_group,
        \"gc":        0,
        \"data":      data
        \}
  return item
endfu


fu! s:RenderBuffer.GetItemByPos() dict abort
  let idx = line('.') - 1

  if len(self.items) == idx
    return 0
  endif

  let column = col('.')
  let line   = self.items[idx]

  for item in line
    if item.start_col <= column && (item.end_col >= column || item.end_col == -1 )
      return item
    endif
  endfor

  return 0
endfu

" not optimal, but ok for current ui with around ~100/200 lines
" COMPLEXITY: N+1
" TODO: add index like structure
fu! s:RenderBuffer.GetItemLineNumber(item) dict abort
  let i = 1
  for line in self.items
    for item in line
      if item == a:item
        return i
      endif
    endfor

    let i += 1
  endfor

  return 0
endfu

" ----------------------------------------------
" Functions
" ----------------------------------------------

fu! s:current_filetype_lang_map() abort
  let ft = &l:filetype
  return get(s:lang_map, ft)
endfu

fu! s:new_grep_result() abort
  let dict = { "line_number": 0, "path": 0, "text": 0 }
  return dict
endfu

fu! s:search_rg(lang, keyword) abort
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

    " change word boundaries
    let regexp = substitute(regexp, '\\<', '\\b', 'g')
    let regexp = substitute(regexp, '\\>', '\\b', 'g')

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
endfu

fu! s:create_ui(grep_results, source_win_id, keyword) abort
  if len(a:grep_results) == 0
    return 0
  endif

  " creates a scratch, unlisted, new, empty, unnamed buffer
  " to be used in the floating window
  let buf = nvim_create_buf(v:false, v:true)

  " nvim_buf_set_keymap(buf, 'n' ...)
  call nvim_buf_set_option(buf, 'filetype', 'any-jump')
  call nvim_buf_set_option(buf, 'bufhidden', 'delete')
  call nvim_buf_set_option(buf, 'buftype', 'nofile')
  call nvim_buf_set_option(buf, 'modifiable', v:true)

  let height = float2nr(&lines * 0.6)
  let width = float2nr(&columns * 0.6)
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

  " TODO: remove
  let b:grep_results = a:grep_results

  let b:render        = s:RenderBuffer.New(buf)
  let b:source_win_id = a:source_win_id

  " move ui drawing to method?
  call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])

  call b:render.AddLine([
    \b:render.CreateItem("text", ">", 0, 2, "Comment"),
    \b:render.CreateItem("text", a:keyword, 1, -1, "Identifier"),
    \b:render.CreateItem("text", "definitions", 1, -1, "Comment"),
    \])

  call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])

  " draw grep results
  let idx = 0
  let first_item = 0
  for gr in a:grep_results
    if g:any_jump_definitions_results_list_style == 1
      let path_text = ' ' .  gr.path .  ":" . gr.line_number

      let matched_text = b:render.CreateItem("link", gr.text, 0, -1, "Statement",
            \{"path": gr.path, "line_number": gr.line_number})

      let file_path = b:render.CreateItem("link", path_text, 0, -1, "String",
            \{"path": gr.path, "line_number": gr.line_number})

      call b:render.AddLine([ matched_text, file_path ])
    elseif g:any_jump_definitions_results_list_style == 2
      let path_text = gr.path .  ":" . gr.line_number

      let matched_text = b:render.CreateItem("link", " " . gr.text, 0, -1, "Statement",
            \{"path": gr.path, "line_number": gr.line_number})

      let file_path = b:render.CreateItem("link", path_text, 0, -1, "String",
            \{"path": gr.path, "line_number": gr.line_number})

      call b:render.AddLine([ file_path, matched_text ])
    endif

    if idx == 0
      let first_item = matched_text
    endif

    let idx += 1
  endfor

  let first_item_ln = b:render.GetItemLineNumber(first_item)
  call cursor(first_item_ln, 2)

  call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])

  call b:render.AddLine([ b:render.CreateItem("help_link", "> Help", 0, -1, "Comment") ])

  call b:render.AddLine([ b:render.CreateItem("help_text", "", 0, -1, "Comment") ])
  call b:render.AddLine([ b:render.CreateItem("help_text", "[o/enter] open file   [tab/p] preview file", 0, -1, "String") ])
  call b:render.AddLine([ b:render.CreateItem("help_text", "", 0, -1, "Comment") ])

  " call b:render.AddLine([ b:render.CreateItem("button", "[u] + search usages", 0, -1, "Identifier") ])
  " call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])

  " call b:render.AddLine([ b:render.CreateItem("button", "[f] + search file names", 0, -1, "Identifier") ])


  " call b:render.AddLine([ b:render.CreateItem("button", "[c] + search cross projects", 0, -1, "Identifier") ])
  " call b:render.AddLine([ b:render.CreateItem("text", "", 0, -1, "Comment") ])

  " call b:render.AddLine([ b:render.CreateItem("button", "[s] save search   [S] clean search   [N] next saved   [P] previous saved", 0, -1, "Identifier") ])

  call nvim_buf_set_option(buf, 'modifiable', v:false)
endfu

fu! s:jump() abort
  " check current language
  if (type(s:current_filetype_lang_map()) == v:t_list) == v:false
    call s:log("not found map definition for filetype " . string(&l:filetype))
    return
  endif

  let keyword  = ''

  let cur_mode   = mode()
  let cur_win_id = win_findbuf(bufnr())[0]

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

  let w:any_jump_last_results = grep_results
  let w:any_jump_last_keyword = keyword

  call s:create_ui(grep_results, cur_win_id, keyword)
endfu

fu! s:jump_back() abort
  if exists('w:any_jump_prev_buf_id')
    let new_prev_buf_id = bufnr()

    execute ":buf " . w:any_jump_prev_buf_id
    let w:any_jump_prev_buf_id = new_prev_buf_id
  endif
endfu

fu! s:jump_last_results() abort
  if exists('w:any_jump_last_results') && exists('w:any_jump_last_keyword')
    if type(w:any_jump_last_results) != v:t_list
      return
    endif

    let cur_win_id = win_findbuf(bufnr())[0]
    call s:create_ui(w:any_jump_last_results, cur_win_id, w:any_jump_last_keyword)
  endif
endfu

fu! s:init() abort
  call s:run_tests()
endfu

fu! g:AnyJumpHandleOpen() abort
  if exists('b:render') && type(b:render) != v:t_dict
    return
  endif

  let action_item = b:render.GetItemByPos()
  if type(action_item) != v:t_dict
    return 0
  endif

  " extract link from preview data
  if action_item.type == 'preview_text' && type(action_item.data.link) == v:t_dict
    let action_item = action_item.data.link
  endif

  if action_item.type == 'link'
    if exists('b:source_win_id') && type(b:source_win_id) == v:t_number
      let win_id = b:source_win_id

      " close ui
      close!

      " jump to definition
      call win_gotoid(win_id)

      let buf_id = bufnr()
      let w:any_jump_prev_buf_id = buf_id

      execute "edit " . action_item.data.path . '|:' . string(action_item.data.line_number)
    endif
  endif
endfu

fu! g:AnyJumpHandleClose() abort
  if exists('b:render')
    close!
  endif
endfu

fu! g:AnyJumpHandlePreview() abort
  if type(b:render) != v:t_dict
    return
  endif

  call nvim_buf_set_option(bufnr(), 'modifiable', v:true)

  let current_previewed_links = []
  let action_item             = b:render.GetItemByPos()

  " remove all previews
  if b:render.preview_opened

    let idx              = 0
    let start_preview_ln = 0

    for line in b:render.items

      if line[0].type == 'preview_text'
        let line[0].gc = v:true " mark for destroy

        let prev_line = b:render.items[idx - 1]

        if type(prev_line[0]) == v:t_dict && prev_line[0].type == 'link'
          call add(current_previewed_links, prev_line[0])
        endif

        if start_preview_ln == 0
          let start_preview_ln = idx + 1
        endif

        " remove from ui
        call deletebufline(b:render.buf_id, start_preview_ln)

      elseif line[0].type == 'help_link'
        echo "help link remove"
      else
        let start_preview_ln = 0
      endif

      let idx += 1
    endfor

    " remove marked for garbage collection lines
    let new_items = []

    for line in b:render.items
      if line[0].gc != v:true
        call add(new_items, line)
      endif
    endfor

    let b:render.items = new_items

    " reset state
    let b:render.preview_opened = v:false
  end

  " if clicked on just opened preview
  " then just close, not open again
  if index(current_previewed_links, action_item) >= 0
    return
  endif

  if type(action_item) == v:t_dict
    if action_item.type == 'link'
      let file_ln               = action_item.data.line_number
      let preview_before_offset = 2
      let preview_after_offset  = 5
      let preview_end_ln        = file_ln + preview_after_offset

      let path = join([getcwd(), action_item.data.path], '/')
      let cmd  = 'head -n ' . string(preview_end_ln) . ' ' . path
            \ . ' | tail -n ' . string(preview_after_offset + 1 + preview_before_offset)

      let preview = split(system(cmd), "\n")

      " insert
      let render_ln = b:render.GetItemLineNumber(action_item)
      for line in preview
        let new_item = b:render.CreateItem("preview_text", line, 0, -1, "Comment", { "link": action_item })
        call b:render.AddLineAt([ new_item ], render_ln)

        let render_ln += 1
      endfor

      let b:render.preview_opened = v:true
    elseif action_item.type == 'help_link'
      echo "link text"
    endif
  endif

  call nvim_buf_set_option(bufnr(), 'modifiable', v:false)
endfu

fu! s:dump_state() abort
  if exists('b:render')
    echo "items -> " . b:render.len()
  endif
endfu

" Commands
command! AnyJumpToggleDebug call s:toggle_debug()
command! AnyJump call s:jump()
command! AnyJumpBack call s:jump_back()
command! AnyJumpLastResults call s:jump_last_results()
command! AnyJumpDumpState call s:dump_state()

" Bindings
au FileType any-jump nnoremap <buffer> o :call g:AnyJumpHandleOpen()<cr>
au FileType any-jump nnoremap <buffer><CR> :call g:AnyJumpHandleOpen()<cr>
au FileType any-jump nnoremap <buffer> p :call g:AnyJumpHandlePreview()<cr>
au FileType any-jump nnoremap <buffer> <tab> :call g:AnyJumpHandlePreview()<cr>
au FileType any-jump nnoremap <buffer> q :call g:AnyJumpHandleClose()<cr>

nnoremap <leader>aj :AnyJump<CR>
nnoremap <leader>ab :AnyJumpBack<CR>
nnoremap <leader>al :AnyJumpLastResults<CR>

call s:init()
