" TODO:
" - impl all rules from dumb-jump
" - update README
" - create doc
"
" TODO_THINK:
" - after pressing p jump to next result
" - add auto preview option
" - optimize regexps processing (do most job at first lang?)
" - add failed tests run & move test load to separate command
" - impl VimL rules
"
" TODO_FUTURE_RELEASES:
" - hl keyword line in preview
" - paths priorities for better search results
" - AnyJumpPreview
" - AnyJumpFirst
"
" TODO_MAYBE:
" - add tags file search support (ctags)
" - compact/full ui mode
"
" - jumps history & jumps work flow
" - add "save search" button
" - saved searches list

" === Plugin options ===

fu! s:set_plugin_global_option(option_name, default_value) abort
  if !exists('g:' .  a:option_name)
    let g:{a:option_name} = a:default_value
  endif
endfu

" Cursor keyword selection mode
"
" on line:
"
" "MyNamespace::MyClass"
"                  ^
"
" then cursor is on MyClass word
"
" 'word' - will match 'MyClass'
" 'full' - will match 'MyNamespace::MyClass'

call s:set_plugin_global_option('any_jump_keyword_match_cursor_mode', 'word')

" Ungrouped results ui variants:
" - 'filename_first'
" - 'filename_last'
call s:set_plugin_global_option('any_jump_results_ui_style', 'filename_first')

" Show line numbers in search rusults
call s:set_plugin_global_option('any_jump_list_numbers', v:false)

" Auto search usages
call s:set_plugin_global_option('any_jump_usages_enabled', v:true)

" Auto group results by filename
call s:set_plugin_global_option('any_jump_grouping_enabled', v:false)

" Amount of preview lines for each search result
call s:set_plugin_global_option('any_jump_preview_lines_count', 5)

" Max search results, other results can be opened via [a]
call s:set_plugin_global_option('any_jump_max_search_results', 10)

" Prefered search engine: rg or ag
call s:set_plugin_global_option('any_jump_search_prefered_engine', 'rg')

" Disable default keybindinngs for commands
call s:set_plugin_global_option('any_jump_disable_default_keybindings', v:false)

" Any-jump window size & position options
call s:set_plugin_global_option('any_jump_window_width_ratio', 0.6)
call s:set_plugin_global_option('any_jump_window_height_ratio', 0.6)
call s:set_plugin_global_option('any_jump_window_top_offset', 2)

" TODO: NOT_IMPLEMENTED:

" Preview next available search result after pressing preview button
" let g:any_jump_follow_previews = v:true

" ----------------------------------------------
" Functions
" ----------------------------------------------

fu! s:CreateUi(internal_buffer) abort
  let buf = nvim_create_buf(v:false, v:true)

  call nvim_buf_set_option(buf, 'filetype', 'any-jump')
  call nvim_buf_set_option(buf, 'bufhidden', 'delete')
  call nvim_buf_set_option(buf, 'buftype', 'nofile')
  call nvim_buf_set_option(buf, 'modifiable', v:true)

  let height     = float2nr(&lines * g:any_jump_window_height_ratio)
  let width      = float2nr(&columns * g:any_jump_window_width_ratio)
  let horizontal = float2nr((&columns - width) / 2)
  let vertical   = g:any_jump_window_top_offset

  let opts = {
        \ 'relative': 'editor',
        \ 'row': vertical,
        \ 'col': horizontal,
        \ 'width': width,
        \ 'height': height
        \ }

  call nvim_open_win(buf, v:true, opts)

  let b:ui = a:internal_buffer
  call b:ui.RenderUi()
  call b:ui.JumpToFirstOfType('link', 'definitions')
endfu

fu! s:Jump() abort
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
  endif

  if len(keyword) == 0
    return
  endif

  let grep_results = search#SearchDefinitions(&l:filetype, keyword)

  let ib = internal_buffer#GetClass().New()
  let ib.keyword                  = keyword
  let ib.language                 = &l:filetype
  let ib.source_win_id            = cur_win_id
  let ib.grouping_enabled         = g:any_jump_grouping_enabled
  let ib.definitions_grep_results = grep_results

  if g:any_jump_usages_enabled || len(grep_results) == 0
    let ib.usages_opened       = v:true
    let usages_grep_results    = search#SearchUsages(ib)
    let ib.usages_grep_results = usages_grep_results
  endif

  let w:any_jump_last_ib = ib
  call s:CreateUi(ib)
endfu

fu! s:JumpBack() abort
  if exists('w:any_jump_prev_buf_id')
    let new_prev_buf_id = winbufnr(winnr())

    execute ":buf " . w:any_jump_prev_buf_id
    let w:any_jump_prev_buf_id = new_prev_buf_id
  endif
endfu

fu! s:JumpLastResults() abort
  if exists('w:any_jump_last_ib')
    let cur_win_id = win_findbuf(bufnr())[0]
    let w:any_jump_last_ib.source_win_id = cur_win_id

    call s:CreateUi(w:any_jump_last_ib)
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
  elseif action_item.type == 'more_button'
    call g:AnyJumpToggleAllResults()
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

  if !has_key(b:ui, 'keyword') || !has_key(b:ui, 'language')
    return
  endif

  " close current opened usages
  " TODO: move to method
  if b:ui.usages_opened
    let b:ui.usages_opened = v:false

    let idx            = 0
    let layer_start_ln = 0
    let usages_started = v:false

    call b:ui.StartUiTransaction(bufnr())

    for line in b:ui.items
      if has_key(line[0], 'data') && type(line[0].data) == v:t_dict
            \ && has_key(line[0].data, 'layer')
            \ && line[0].data.layer == 'usages'

        let line[0].gc = v:true " mark for destroy

        if !layer_start_ln
          let layer_start_ln = idx + 1
          let usages_started = v:true
        endif

        " remove from ui
        call deletebufline(bufnr(), layer_start_ln)

      " remove preview lines for usages
      elseif usages_started && line[0].type == 'preview_text'
        let line[0].gc = v:true
        call deletebufline(bufnr(), layer_start_ln)
      else
        let layer_start_ln = 0
      endif

      let idx += 1
    endfor

    call b:ui.EndUiTransaction(bufnr())
    call b:ui.RemoveGarbagedLines()

    call b:ui.JumpToFirstOfType('link', 'definitions')

    let b:ui.usages_opened = v:false

    return v:true
  endif

  let grep_results  = search#SearchUsages(b:ui)
  let filtered      = []

  " filter out results found in definitions
  for result in grep_results
    if index(b:ui.definitions_grep_results, result) == -1
      " not effective? ( TODO: deletion is more memory effective)
      call add(filtered, result)
    endif
  endfor

  let b:ui.usages_opened       = v:true
  let b:ui.usages_grep_results = filtered

  let marker_item = b:ui.GetFirstItemOfType('help_link')

  let start_ln = b:ui.GetItemLineNumber(marker_item) - 1

  call b:ui.StartUiTransaction(bufnr())
  call b:ui.RenderUiUsagesList(b:ui.usages_grep_results, start_ln)
  call b:ui.EndUiTransaction(bufnr())

  call b:ui.JumpToFirstOfType('link', 'usages')
endfu

fu! g:AnyJumpToFirstLink() abort
  if !exists('b:ui')
    return
  endif

  call b:ui.JumpToFirstOfType('link')

  return v:true
endfu

fu! g:AnyJumpToggleGrouping() abort
  if !exists('b:ui')
    return
  endif

  let buf         = bufnr()
  let cursor_item = b:ui.TryFindOriginalLinkFromPos()

  call b:ui.StartUiTransaction(buf)
  call b:ui.ClearBuffer(buf)

  let b:ui.preview_opened   = v:false
  let b:ui.grouping_enabled = b:ui.grouping_enabled ? v:false : v:true

  call b:ui.RenderUi()
  call b:ui.EndUiTransaction(buf)

  call b:ui.TryRestoreCursorForItem(cursor_item)
endfu

fu! g:AnyJumpToggleAllResults() abort
  if !exists('b:ui')
    return
  endif

  let buf = bufnr()

  let b:ui.overmaxed_results_hidden =
        \ b:ui.overmaxed_results_hidden ? v:false : v:true

  call b:ui.StartUiTransaction(buf)

  let cursor_item = b:ui.TryFindOriginalLinkFromPos()

  call b:ui.ClearBuffer(buf)

  let b:ui.preview_opened = v:false

  call b:ui.RenderUi()
  call b:ui.EndUiTransaction(buf)

  call b:ui.TryRestoreCursorForItem(cursor_item)
endfu

fu! g:AnyJumpHandlePreview() abort
  if !exists('b:ui')
    return
  endif

  call b:ui.StartUiTransaction(bufnr())

  let current_previewed_links = []
  let action_item = b:ui.GetItemByPos()

  " dispatch to other items handler
  if type(action_item) == v:t_dict && action_item.type == 'more_button'
    call g:AnyJumpToggleAllResults()
    return
  endif

  " remove all previews
  if b:ui.preview_opened
    let idx            = 0
    let layer_start_ln = 0

    for line in b:ui.items
      if line[0].type == 'preview_text'
        let line[0].gc = v:true " mark for destroy

        let prev_line = b:ui.items[idx - 1]

        if type(prev_line[0]) == v:t_dict && prev_line[0].type == 'link'
          call add(current_previewed_links, prev_line[0])
        endif

        if !layer_start_ln
          let layer_start_ln = idx + 1
        endif

        " remove from ui
        call deletebufline(bufnr(), layer_start_ln)

      elseif line[0].type == 'help_link'
        " not implemeted
      else
        let layer_start_ln = 0
      endif

      let idx += 1
    endfor

    call b:ui.RemoveGarbagedLines()
    let b:ui.preview_opened = v:false
  end

  " if clicked on just opened preview
  " then just close, not open again
  if index(current_previewed_links, action_item) >= 0
    return
  endif

  if type(action_item) == v:t_dict
    if action_item.type == 'link' && !has_key(action_item.data, "group_header")
      let file_ln               = action_item.data.line_number
      let preview_before_offset = 2
      let preview_after_offset  = g:any_jump_preview_lines_count
      let preview_end_ln        = file_ln + preview_after_offset

      let path = join([getcwd(), action_item.data.path], '/')
      let cmd  = 'head -n ' . string(preview_end_ln) . ' ' . path
            \ . ' | tail -n ' . string(preview_after_offset + 1 + preview_before_offset)

      let preview = split(system(cmd), "\n")

      " TODO: move to func
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

  call b:ui.EndUiTransaction(bufnr())
endfu


" ----------------------------------------------
" Script & Service functions
" ----------------------------------------------

if !exists('s:debug')
  let s:debug = v:false
endif

fu! s:ToggleDebug()
  let s:debug = s:debug ? v:false : v:true

  echo "debug enabled: " . s:debug
endfu

fu! s:log(message)
  echo "[any-jump] " . a:message
endfu

fu! s:log_debug(message)
  if s:debug == v:true
    echo "[any-jump] " . a:message
  endif
endfu

fu! s:RunSpecs() abort
  let errors = []
  let errors += search#RunSearchEnginesSpecs()
  let errors += search#RunRegexpSpecs()

  if len(errors) > 0
    for error in errors
      echo error
    endfor
  endif

  call s:log("Tests finished")
endfu

" Commands
command! AnyJump call s:Jump()
command! AnyJumpBack call s:JumpBack()
command! AnyJumpLastResults call s:JumpLastResults()
command! AnyJumpRunSpecs call s:RunSpecs()

" KeyBindings
au FileType any-jump nnoremap <buffer> o :call g:AnyJumpHandleOpen()<cr>
au FileType any-jump nnoremap <buffer><CR> :call g:AnyJumpHandleOpen()<cr>
au FileType any-jump nnoremap <buffer> p :call g:AnyJumpHandlePreview()<cr>
au FileType any-jump nnoremap <buffer> <tab> :call g:AnyJumpHandlePreview()<cr>
au FileType any-jump nnoremap <buffer> q :call g:AnyJumpHandleClose()<cr>
au FileType any-jump nnoremap <buffer> <esc> :call g:AnyJumpHandleClose()<cr>
au FileType any-jump nnoremap <buffer> u :call g:AnyJumpHandleUsages()<cr>
au FileType any-jump nnoremap <buffer> U :call g:AnyJumpHandleUsages()<cr>
au FileType any-jump nnoremap <buffer> b :call g:AnyJumpToFirstLink()<cr>
au FileType any-jump nnoremap <buffer> T :call g:AnyJumpToggleGrouping()<cr>
au FileType any-jump nnoremap <buffer> a :call g:AnyJumpToggleAllResults()<cr>
au FileType any-jump nnoremap <buffer> A :call g:AnyJumpToggleAllResults()<cr>

if g:any_jump_disable_default_keybindings == v:false
  nnoremap <leader>j  :AnyJump<CR>
  nnoremap <leader>ab :AnyJumpBack<CR>
  nnoremap <leader>al :AnyJumpLastResults<CR>
end
