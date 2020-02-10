" POINTS:

" TODO:
" - [ ] При не сохраненном файле вылетает ошибка на jump'е
" - [ ] AnyJumpFirst
" - [ ] add failed tests run & move test load to separate command
" - [+] save winid, not bufid for correct focus change
" - [ ] add "save search" button
" - [ ] add save jumps lists inside popup window
" - [ ] add grouping for results
" - [ ] add cache
" - [ ] optimize regexps processing (do most job at first lang?)
" - [ ] THINK_NOT: compact/full ui mode
" - [ ] THINK: hl keyword line in preview
" - [ ] THINK: async load of additional searches
" - [ ] THINK: start async requests after some timeout of main rg request

" let g:any_jump_loaded = v:true

" Options:

" Cursor keyword match mode
"
" in line:
" "MyNamespace::MyClass"
"
" then cursor is on MyClass word
"
" 'word' - will match MyClass
" 'full' - will match MyNamespace::MyClass
let g:any_jump_keyword_match_cursor_mode = 'word'

" File list results ui variants
"
" available variants: 1/2
let g:any_jump_definitions_results_list_style = 1


" ----------------------------------------------
" Functions
" ----------------------------------------------

fu! s:new_grep_result() abort
  let dict = { "line_number": 0, "path": 0, "text": 0 }
  return dict
endfu

fu! s:search_usages_rg(lang, keyword) abort
  let cmd          = "rg -n --json -t " . a:lang . ' -w ' . a:keyword
  echo "cmd -> " . cmd

  let raw_results  = system(cmd)
  let grep_results = []

  echo "res -> " . raw_results
endfu

fu! s:search_rg(lang, keyword) abort
  let patterns = []
  let lang     = lang_map#get_definitions(a:lang)

  for rule in lang
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

  let b:ui = internal_buffer#GetClass().New(buf)
  let b:ui.source_win_id = a:source_win_id

  " move ui drawing to method?
  call b:ui.AddLine([ b:ui.CreateItem("text", "", 0, -1, "Comment") ])

  call b:ui.AddLine([
    \b:ui.CreateItem("text", ">", 0, 2, "Comment"),
    \b:ui.CreateItem("text", a:keyword, 1, -1, "Identifier"),
    \b:ui.CreateItem("text", "definitions", 1, -1, "Comment"),
    \])

  call b:ui.AddLine([ b:ui.CreateItem("text", "", 0, -1, "Comment") ])

  " draw grep results
  let idx = 0
  let first_item = 0
  for gr in a:grep_results
    if g:any_jump_definitions_results_list_style == 1
      let path_text = ' ' .  gr.path .  ":" . gr.line_number

      let matched_text = b:ui.CreateItem("link", gr.text, 0, -1, "Statement",
            \{"path": gr.path, "line_number": gr.line_number})

      let file_path = b:ui.CreateItem("link", path_text, 0, -1, "String",
            \{"path": gr.path, "line_number": gr.line_number})

      call b:ui.AddLine([ matched_text, file_path ])
    elseif g:any_jump_definitions_results_list_style == 2
      let path_text = gr.path .  ":" . gr.line_number

      let matched_text = b:ui.CreateItem("link", " " . gr.text, 0, -1, "Statement",
            \{"path": gr.path, "line_number": gr.line_number})

      let file_path = b:ui.CreateItem("link", path_text, 0, -1, "String",
            \{"path": gr.path, "line_number": gr.line_number})

      call b:ui.AddLine([ file_path, matched_text ])
    endif

    if idx == 0
      let first_item = matched_text
    endif

    let idx += 1
  endfor

  let first_item_ln = b:ui.GetItemLineNumber(first_item)
  call cursor(first_item_ln, 2)

  call b:ui.AddLine([ b:ui.CreateItem("text", "", 0, -1, "Comment") ])

  call b:ui.AddLine([ b:ui.CreateItem("help_link", "> Help", 0, -1, "Comment") ])

  call b:ui.AddLine([ b:ui.CreateItem("help_text", "", 0, -1, "Comment") ])
  call b:ui.AddLine([ b:ui.CreateItem("help_text", "[o/enter] open file   [tab/p] preview file   [u] find usages ", 0, -1, "String") ])
  call b:ui.AddLine([ b:ui.CreateItem("help_text", "", 0, -1, "Comment") ])

  " call b:ui.AddLine([ b:ui.CreateItem("button", "[u] + search usages", 0, -1, "Identifier") ])
  " call b:ui.AddLine([ b:ui.CreateItem("text", "", 0, -1, "Comment") ])

  " call b:ui.AddLine([ b:ui.CreateItem("button", "[f] + search file names", 0, -1, "Identifier") ])


  " call b:ui.AddLine([ b:ui.CreateItem("button", "[c] + search cross projects", 0, -1, "Identifier") ])
  " call b:ui.AddLine([ b:ui.CreateItem("text", "", 0, -1, "Comment") ])

  " call b:ui.AddLine([ b:ui.CreateItem("button", "[s] save search   [S] clean search   [N] next saved   [P] previous saved", 0, -1, "Identifier") ])

  call nvim_buf_set_option(buf, 'modifiable', v:false)
endfu

fu! s:jump() abort
  " check current language
  if !lang_map#lang_exists(&l:filetype)
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
    let new_prev_buf_id = winbufnr(winnr())

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

" ----------------------------------------------
" Event Handlers
" ----------------------------------------------

fu! g:AnyJumpHandleOpen() abort
  if exists('b:ui') && type(b:ui) != v:t_dict
    return
  endif

  let action_item = b:ui.GetItemByPos()
  if type(action_item) != v:t_dict
    return 0
  endif

  " extract link from preview data
  if action_item.type == 'preview_text' && type(action_item.data.link) == v:t_dict
    let action_item = action_item.data.link
  endif

  if action_item.type == 'link'
    if has_key(b:ui, 'source_win_id') && type(b:ui.source_win_id) == v:t_number
      let win_id = b:ui.source_win_id

      " close buffer
      " THINK: TODO: buffer remove options/behaviour?
      close!

      " jump to definition
      call win_gotoid(win_id)

      let buf_id = winbufnr(winnr())
      let w:any_jump_prev_buf_id = buf_id

      execute "edit " . action_item.data.path . '|:' . string(action_item.data.line_number)
    endif
  endif
endfu

fu! g:AnyJumpHandleClose() abort
  if exists('b:ui')
    close!
  endif
endfu

fu! g:AnyJumpHandleUsages() abort
  if !exists('b:ui')
    return
  endif

  " check current language
  if !lang_map#lang_exists(&l:filetype)
    call s:log("not found map definition for filetype " . string(&l:filetype))
    return
  endif

  let keyword  = ''

  let cur_mode   = mode()
  let cur_win_id = win_findbuf(winbufnr())[0]

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

  let grep_results = s:search_usages_rg(&l:filetype, keyword)
endfu

fu! g:AnyJumpHandlePreview() abort
  if type(b:ui) != v:t_dict
    return
  endif

  call nvim_buf_set_option(bufnr(), 'modifiable', v:true)

  let current_previewed_links = []
  let action_item             = b:ui.GetItemByPos()

  " remove all previews
  if b:ui.preview_opened

    let idx              = 0
    let start_preview_ln = 0

    for line in b:ui.items

      if line[0].type == 'preview_text'
        let line[0].gc = v:true " mark for destroy

        let prev_line = b:ui.items[idx - 1]

        if type(prev_line[0]) == v:t_dict && prev_line[0].type == 'link'
          call add(current_previewed_links, prev_line[0])
        endif

        if start_preview_ln == 0
          let start_preview_ln = idx + 1
        endif

        " remove from ui
        call deletebufline(b:ui.buf_id, start_preview_ln)

      elseif line[0].type == 'help_link'
        echo "help link remove"
      else
        let start_preview_ln = 0
      endif

      let idx += 1
    endfor

    " remove marked for garbage collection lines
    let new_items = []

    for line in b:ui.items
      if line[0].gc != v:true
        call add(new_items, line)
      endif
    endfor

    let b:ui.items = new_items

    " reset state
    let b:ui.preview_opened = v:false
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
      let render_ln = b:ui.GetItemLineNumber(action_item)
      for line in preview
        let new_item = b:ui.CreateItem("preview_text", line, 0, -1, "Comment", { "link": action_item })
        call b:ui.AddLineAt([ new_item ], render_ln)

        let render_ln += 1
      endfor

      let b:ui.preview_opened = v:true
    elseif action_item.type == 'help_link'
      echo "link text"
    endif
  endif

  call nvim_buf_set_option(bufnr(), 'modifiable', v:false)
endfu


" ----------------------------------------------
" Script & Service functions
" ----------------------------------------------

let s:debug = v:true

fu! s:toggle_debug()
  let s:debug = s:debug ? v:false : v:true

  echo "debug enabled: " . s:debug
endfu

fu! s:log(message)
  echo "[smart-jump] " . a:message
endfu

fu! s:log_debug(message)
  if s:debug == v:true
    echo "[smart-jump] " . a:message
  endif
endfu

fu! s:run_tests()
  let errors = []
  let errors += lang_map#regexp_tests()

  if len(errors) > 0
    for error in errors
      echo error
    endfor
  endif

  call s:log("Tests finished")
endfu

fu! s:init() abort
  if s:debug
    call s:run_tests()
  end
endfu

" Commands
command! AnyJumpToggleDebug call s:toggle_debug()
command! AnyJump call s:jump()
command! AnyJumpBack call s:jump_back()
command! AnyJumpLastResults call s:jump_last_results()

" Bindings
au FileType any-jump nnoremap <buffer> o :call g:AnyJumpHandleOpen()<cr>
au FileType any-jump nnoremap <buffer><CR> :call g:AnyJumpHandleOpen()<cr>
au FileType any-jump nnoremap <buffer> p :call g:AnyJumpHandlePreview()<cr>
au FileType any-jump nnoremap <buffer> <tab> :call g:AnyJumpHandlePreview()<cr>
au FileType any-jump nnoremap <buffer> q :call g:AnyJumpHandleClose()<cr>
au FileType any-jump nnoremap <buffer> u :call g:AnyJumpHandleUsages()<cr>

nnoremap <leader>aj :AnyJump<CR>
nnoremap <leader>ab :AnyJumpBack<CR>
nnoremap <leader>al :AnyJumpLastResults<CR>

" run tests for debug
" init lang map
call s:init()
