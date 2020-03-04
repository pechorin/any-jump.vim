" TODO:
" - >> если нажать [a] show all results потом промотать потом снова [a] то приходится назад мотать долго - мб как то в начало списка кидать в таком кейсе?
"
" - create doc
"
" - handle many search results
"
" - cursor keyword search modes
"
" - paths priorities for better search results
"
" TODO_THINK:
" - rg and ag results sometimes very differenet
" - after pressing p jump to next result
" - add auto preview option
" - impl VimL rules
" - fzf
" - добавить возможность открывать окно не только в текущем window, но и
"   делать vsplit/split относительного него
"
" TODO_FUTURE_RELEASES:
" - [nvim] >> Once a focus to the floating window is lost, the window should disappear. Like many other plugins with floating window.
" - AnyJumpPreview
" - AnyJumpFirst
" - jumps history & jumps work flow
" - add tags file search support (ctags)
" - "save jump" button
" - jumps list

" === Vim version check
let s:nvim = has('nvim')

fu! s:host_vim_errors() abort
  let errors = []

  if s:nvim
    if !exists('*nvim_open_win')
      call add(errors, "nvim_open_win support required")
    endif
  else
    if !exists('*popup_menu')
      call add(errors, "popup_menu support required")
    endif
  endif

  return errors
endfu

let errors = s:host_vim_errors()

if len(errors)
  echoe "any-jump can't be loaded: " . join(errors, ', ')
  finish
endif

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
call s:set_plugin_global_option('any_jump_window_width_ratio', str2float('0.6'))
call s:set_plugin_global_option('any_jump_window_height_ratio', str2float('0.6'))
call s:set_plugin_global_option('any_jump_window_top_offset', 2)

" Remove comments line from search results (default: 1)
call s:set_plugin_global_option('any_jump_remove_comments_from_results', v:true)

" TODO: NOT_IMPLEMENTED:

" Preview next available search result after pressing preview button
" let g:any_jump_follow_previews = v:true

" ----------------------------------------------
" Functions
" ----------------------------------------------

fu! s:CreateUi(internal_buffer) abort
  if s:nvim
    call s:CreateNvimUi(a:internal_buffer)
  else
    call s:CreateVimUi(a:internal_buffer)
  endif
endfu

fu! s:CreateNvimUi(internal_buffer) abort
  let kw  = a:internal_buffer.keyword
  let buf = bufadd('any-jump lookup ' . kw)

  call setbufvar(buf, '&filetype', 'any-jump')
  call setbufvar(buf, '&bufhidden', 'delete')
  call setbufvar(buf, '&buftype', 'nofile')
  call setbufvar(buf, '&modifiable', 1)

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

  let t:any_jump.vim_bufnr = buf

  call t:any_jump.RenderUi()
  call t:any_jump.JumpToFirstOfType('link', 'definitions')
endfu

fu! s:CreateVimUi(internal_buffer) abort
  let l:Filter   = function("s:VimPopupFilter")

  let popup_winid = popup_menu([], {
        \"wrap":       0,
        \"cursorline": 1,
        \"minheight":  20,
        \"maxheight":  30,
        \"minwidth":   90,
        \"maxwidth":   90,
        \"border":     [0,0,0,0],
        \"padding":    [0,1,1,1],
        \"filter":     Filter,
        \})

  let a:internal_buffer.popup_winid = popup_winid
  let a:internal_buffer.vim_bufnr   = winbufnr(popup_winid)

  call a:internal_buffer.RenderUi()
endfu

fu! s:VimPopupFilter(popup_winid, key) abort
  let bufnr = winbufnr(a:popup_winid)
  let ib    = s:GetCurrentInternalBuffer()

  if a:key == "j"
    call popup_filter_menu(a:popup_winid, a:key)
    return 1

  elseif a:key == "k"
    call popup_filter_menu(a:popup_winid, a:key)
    return 1

  elseif a:key == "p" || a:key == "\<TAB>"
    call g:AnyJumpHandlePreview()
    return 1

  elseif a:key == "a" || a:key == "A"
    call g:AnyJumpToggleAllResults()
    return 1

  elseif a:key == "u" || a:key == "U"
    call g:AnyJumpHandleUsages()
    return 1

  elseif a:key == "T"
    call g:AnyJumpToggleGrouping()
    return 1

  elseif a:key == "L"
    call g:AnyJumpToggleListStyle()
    return 1

  elseif a:key == "\<CR>" || a:key == 'o' || a:key == 'O'
    let item = t:any_jump.TryFindOriginalLinkFromPos()

    if type(item) == v:t_dict
      call g:AnyJumpHandleOpen()
      return 1
    else
      return 1
    endif

  elseif a:key == "q"
        \ || a:key == '\<ESC>'
        \ || a:key == 'Q'
        \ || a:key == 'x'
    call g:AnyJumpHandleClose()
    return 1
  endif

  call g:AnyJumpHandleClose()
  return 1
endfu

fu! s:GetCurrentInternalBuffer() abort
  if exists('t:any_jump')
    return t:any_jump
  else
    throw "any-jump internal buffer lost"
  endif
endfu

fu! s:Jump() abort
  let lang = lang_map#get_language_from_filetype(&l:filetype)

  let keyword    = ''
  let cur_mode   = mode()

  if cur_mode == 'n'
    if g:any_jump_keyword_match_cursor_mode == 'word'
      let keyword = expand('<cword>')
    else
      let keyword = expand('<cWORD>')
    end
  else
    " THINK: implement visual mode selection?
    " https://stackoverflow.com/a/6271254/190454
    call s:log_debug("not implemented for mode " . cur_mode)
  endif

  if len(keyword) == 0
    return
  endif

  let ib = internal_buffer#GetClass().New()

  let ib.keyword                  = keyword
  let ib.language                 = lang
  let ib.source_win_id            = winnr()
  let ib.grouping_enabled         = g:any_jump_grouping_enabled

  if type(lang) == v:t_string
    let ib.definitions_grep_results = search#SearchDefinitions(lang, keyword)
  endif

  if g:any_jump_usages_enabled || len(ib.definitions_grep_results) == 0
    let ib.usages_opened       = v:true
    let usages_grep_results    = search#SearchUsages(ib)
    let ib.usages_grep_results = []

    " filter out results found in definitions
    for result in usages_grep_results
      if index(ib.definitions_grep_results, result) == -1
        " not effective? ( TODO: deletion is more memory effective)
        call add(ib.usages_grep_results, result)
      endif
    endfor
  endif

  " assign any-jump internal buffer to current tab
  let t:any_jump = ib

  call s:CreateUi(ib)
endfu

fu! s:JumpBack() abort
  if exists('t:any_jump') && t:any_jump.previous_bufnr
    let new_previous = bufnr()
    execute(':buf ' . t:any_jump.previous_bufnr)
    let t:any_jump.previous_bufnr = new_previous
  endif
endfu

fu! s:JumpLastResults() abort
  if exists('t:any_jump') " TODO: check for buffer visibility here
    let t:any_jump.source_win_id = winnr()
    call s:CreateUi(t:any_jump)
  endif
endfu

" ----------------------------------------------
" Event Handlers
" ----------------------------------------------

fu! g:AnyJumpHandleOpen() abort
  let ui = s:GetCurrentInternalBuffer()
  let action_item = ui.GetItemByPos()

  if type(action_item) != v:t_dict
    return 0
  endif

  " extract link from preview data
  if action_item.type == 'preview_text' && type(action_item.data.link) == v:t_dict
    let action_item = action_item.data.link
  endif

  if action_item.type == 'link'
    if type(ui.source_win_id) == v:t_number
      let win_id = ui.source_win_id

      if s:nvim
        close!
      else
        call popup_close(ui.popup_winid)
      endif

      " jump to desired window
      call win_gotoid(win_id)

      " save opened buffer for back-history
      let ui.previous_bufnr = bufnr()

      " open new file
      execute "edit " . action_item.data.path . '|:' . string(action_item.data.line_number)
    endif
  elseif action_item.type == 'more_button'
    call g:AnyJumpToggleAllResults()
  endif
endfu

fu! g:AnyJumpHandleClose() abort
  let ui = s:GetCurrentInternalBuffer()

  if s:nvim
    close!
  else
    call popup_close(ui.popup_winid)
  endif
endfu

fu! g:AnyJumpToggleListStyle() abort
  let ui = s:GetCurrentInternalBuffer()
  let next_style = g:any_jump_results_ui_style == 'filename_first' ? 'filename_last' : 'filename_first'
  let g:any_jump_results_ui_style = next_style

  let cursor_item = ui.TryFindOriginalLinkFromPos()

  call ui.StartUiTransaction(ui.vim_bufnr)
  call ui.RenderUi()
  call ui.EndUiTransaction(ui.vim_bufnr)

  call ui.TryRestoreCursorForItem(cursor_item)
endfu

fu! g:AnyJumpHandleUsages() abort
  let ui = s:GetCurrentInternalBuffer()

  " close current opened usages
  " TODO: move to method
  if ui.usages_opened
    let ui.usages_opened = v:false

    let idx            = 0
    let layer_start_ln = 0
    let usages_started = v:false

    call ui.StartUiTransaction(ui.vim_bufnr)

    " TODO: move to separate method RemoveUsages()
    for line in ui.items
      if has_key(line[0], 'data') && type(line[0].data) == v:t_dict
            \ && has_key(line[0].data, 'layer')
            \ && line[0].data.layer == 'usages'

        let line[0].gc = v:true " mark for destroy

        if !layer_start_ln
          let layer_start_ln = idx + 1
          let usages_started = v:true
        endif

        " remove from ui
        call deletebufline(ui.vim_bufnr, layer_start_ln)

      " remove preview lines for usages
      elseif usages_started && line[0].type == 'preview_text'
        let line[0].gc = v:true
        call deletebufline(ui.vim_bufnr, layer_start_ln)
      else
        let layer_start_ln = 0
      endif

      let idx += 1
    endfor

    call ui.EndUiTransaction(ui.vim_bufnr)
    call ui.RemoveGarbagedLines()

    call ui.JumpToFirstOfType('link', 'definitions')

    let ui.usages_opened = v:false

    return v:true
  endif

  let grep_results  = search#SearchUsages(ui)
  let filtered      = []

  " filter out results found in definitions
  for result in grep_results
    if index(ui.definitions_grep_results, result) == -1
      " not effective? ( TODO: deletion is more memory effective)
      call add(filtered, result)
    endif
  endfor

  let ui.usages_opened       = v:true
  let ui.usages_grep_results = filtered

  let marker_item = ui.GetFirstItemOfType('help_link')

  let start_ln = ui.GetItemLineNumber(marker_item)

  call ui.StartUiTransaction(bufnr())
  call ui.RenderUiUsagesList(ui.usages_grep_results, start_ln)
  call ui.EndUiTransaction(bufnr())

  call ui.JumpToFirstOfType('link', 'usages')
endfu

fu! g:AnyJumpToFirstLink() abort
  let ui = s:GetCurrentInternalBuffer()

  call ui.JumpToFirstOfType('link')

  return v:true
endfu

fu! g:AnyJumpToggleGrouping() abort
  let ui = s:GetCurrentInternalBuffer()

  let cursor_item = ui.TryFindOriginalLinkFromPos()

  call ui.StartUiTransaction(ui.vim_bufnr)
  call ui.ClearBuffer(ui.vim_bufnr)

  let ui.preview_opened   = v:false
  let ui.grouping_enabled = ui.grouping_enabled ? v:false : v:true

  call ui.RenderUi()
  call ui.EndUiTransaction(ui.vim_bufnr)

  call ui.TryRestoreCursorForItem(cursor_item)
endfu

fu! g:AnyJumpToggleAllResults() abort
  let ui = s:GetCurrentInternalBuffer()

  let ui.overmaxed_results_hidden =
        \ ui.overmaxed_results_hidden ? v:false : v:true

  call ui.StartUiTransaction(ui.vim_bufnr)

  let cursor_item = ui.TryFindOriginalLinkFromPos()

  call ui.ClearBuffer(ui.vim_bufnr)

  let ui.preview_opened = v:false

  call ui.RenderUi()
  call ui.EndUiTransaction(ui.vim_bufnr)

  call ui.TryRestoreCursorForItem(cursor_item)
endfu

fu! g:AnyJumpHandlePreview() abort
  let ui = s:GetCurrentInternalBuffer()

  call ui.StartUiTransaction(ui.vim_bufnr)

  let current_previewed_links = []
  let action_item = ui.GetItemByPos()

  " dispatch to other items handler
  if type(action_item) == v:t_dict && action_item.type == 'more_button'
    call g:AnyJumpToggleAllResults()
    return
  endif

  " remove all previews
  if ui.preview_opened
    let idx            = 0
    let layer_start_ln = 0

    for line in ui.items
      if line[0].type == 'preview_text'
        let line[0].gc = v:true " mark for destroy

        let prev_line = ui.items[idx - 1]

        if type(prev_line[0]) == v:t_dict && prev_line[0].type == 'link'
          call add(current_previewed_links, prev_line[0])
        endif

        if !layer_start_ln
          let layer_start_ln = idx + 1
        endif

        " remove from ui
        call deletebufline(ui.vim_bufnr, layer_start_ln)

      elseif line[0].type == 'help_link'
        " not implemeted
      else
        let layer_start_ln = 0
      endif

      let idx += 1
    endfor

    call ui.RemoveGarbagedLines()
    let ui.preview_opened = v:false
  endif

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

      let render_ln = ui.GetItemLineNumber(action_item)
      for line in preview
        " TODO: move to method
        let filtered_line = substitute(line, '^\s*', '', 'g')
        let filtered_line = substitute(filtered_line, '\n', '', 'g')

        if filtered_line == action_item.text
          let items        = []
          let cur_text     = line
          let kw           = ui.CreateItem("preview_text", ui.keyword, "Operator", { "link": action_item, "no_padding": v:true })
          let first_kw_pos = match(cur_text, '\<' . ui.keyword . '\>')

          while cur_text != ''

            if first_kw_pos == 0
              call add(items, deepcopy(kw))
              let cur_text = cur_text[first_kw_pos + len(ui.keyword) : -1]

            elseif first_kw_pos == -1
              let tail = cur_text
              let item = ui.CreateItem("preview_text", tail, "Comment", { "link": action_item, "no_padding": v:true })

              call add(items, item)
              let cur_text = ''

            else
              let head = cur_text[0 : first_kw_pos - 1]
              let head_item = ui.CreateItem("preview_text", head, "Comment", { "link": action_item, "no_padding": v:true })

              call add(items, head_item)
              call add(items, deepcopy(kw))

              let cur_text = cur_text[first_kw_pos + len(ui.keyword) : -1]
            endif

            let first_kw_pos = match(cur_text, '\<' . ui.keyword . '\>')
          endwhile
        else
          let items = [ ui.CreateItem("preview_text", line, "Comment", { "link": action_item } ) ]
        endif

        call ui.AddLineAt(items, render_ln + 1)

        let render_ln += 1
      endfor

      let ui.preview_opened = v:true
    elseif action_item.type == 'help_link'
      echo "link text"
    endif
  endif

  call ui.EndUiTransaction(ui.vim_bufnr)
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
      echoe error
    endfor
  endif

  call s:log("Tests finished")
endfu

" Commands
command! AnyJump call s:Jump()
command! AnyJumpBack call s:JumpBack()
command! AnyJumpLastResults call s:JumpLastResults()
command! AnyJumpRunSpecs call s:RunSpecs()

" Window KeyBindings
if s:nvim
  augroup anyjump
    au!
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
    au FileType any-jump nnoremap <buffer> L :call g:AnyJumpToggleListStyle()<cr>
  augroup END
end


if g:any_jump_disable_default_keybindings == v:false
  nnoremap <leader>j  :AnyJump<CR>
  nnoremap <leader>ab :AnyJumpBack<CR>
  nnoremap <leader>al :AnyJumpLastResults<CR>
end
