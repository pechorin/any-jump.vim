" TODO:
" - wrap for nvim should be configurable
" - fix bg in NeoSolorized theme (add bg set color support)
" - [more] button should append N items only on current collection
" - add scope :symbol to ruby syntax
" - add lightline integration ?
" - add mouse-click evets support
" - any-jump-last should also restore cursor position
" - add multiple priview mode
" - ability to toggle help
" - ability to make help hidden by default
" - add definitions rules for rails meta expressions in ruby like `has_many :users`
" - better default syntax (which works for some N popular themes) rules
" - hl keyword in result line also
" - ability to jumps and lookups for library source codes paths
" - [hot] display type of definition
" - [option] cut long lines
" - guide on how to add language
" - AnyJumpFirst - if found result from prefered dirs of only one result
"   then jump to it, othrewise open ui
" - [option] auto preview first result
" - is tags cupport really needed?
"   i think it cool for perfomance reasons, but sometimes our engine is deeper
"
" TAGS_SUPPORT:
" - use tags definitions engine if prefered
" - what kind of additional data we can provide if tags enabled? (besides
"   definitions)A
"
" UI:
" - add rerun search button (first step to refuctoring) (first `R` - rerun
"   search and just show diff only; `RR` -> rerun search and show new results)
"
" TODO_THINK:
" - after pressing p jump to next result
" - fzf
" - ability to scroll preview
" - [vim] может стоит перепрыгивать пустые строки? при j/k
" - support for old vims via opening buffer in split (?)
"
" WILL_NEVER:
" - fzf or quickfix, because any-jump ui is some sort of qf
"   but if you wish to provide any-jump definitions/references search results
"   to fzf or quickfix please create pull request with this core modification.
"
" TODO_FUTURE_RELEASES:
" - [nvim] >> Once a focus to the floating window is lost, the window should disappear. Like many other plugins with floating window.
" - AnyJumpPreview
" - "save jump" button ??
" - jumps list ??

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
call s:set_plugin_global_option('any_jump_references_enabled', v:true)

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

" Search references only for current file type
" (default: false, so will find keyword in all filetypes)
call s:set_plugin_global_option('any_jump_references_only_for_current_filetype', v:false)

" Disable search engine ignore vcs untracked files (default: false, search engine will ignore vcs untracked files)
call s:set_plugin_global_option('any_jump_disable_vcs_ignore', v:false)

" Custom ignore files
" default is: ['*.tmp', '*.temp']
call s:set_plugin_global_option('any_jump_ignored_files', ['*.tmp', '*.temp'])

" ----------------------------------------------
" Public customization methods
" ----------------------------------------------

let s:default_colors = {
      \"plain_text": "Comment",
      \"preview": 'Comment',
      \"preview_keyword": "Operator",
      \"heading_text": "Function",
      \"heading_keyword": "Identifier",
      \"group_text": "Comment",
      \"group_name": "Function",
      \"more_button": "Operator",
      \"more_explain": "Comment",
      \"result_line_number": "Comment",
      \"result_text": "Statement",
      \"result_path": "String",
      \"help": "Comment"
      \}

let g:any_jump_colors_compiled = s:default_colors

if exists('g:any_jump_colors')
  call extend(g:any_jump_colors_compiled, g:any_jump_colors)
endif

" TODO: change to private# api
fu! g:AnyJumpGetColor(name) abort
  if has_key(g:any_jump_colors_compiled, a:name)
    return g:any_jump_colors_compiled[a:name]
  else
    echo "any-jump color not found: " . a:name
    return 'Comment'
  endif
endfu

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
  let buf = nvim_create_buf(1, 0)
  call nvim_buf_set_name(buf, 'any-jump lookup ' . kw)

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
        \ 'height': height,
        \ 'style': 'minimal',
        \ }

  let winid = nvim_open_win(buf, v:true, opts)

  " Set filetype after window appearance for proper event propagation
  call nvim_buf_set_option(buf, 'filetype', 'any-jump')

  call nvim_win_set_option(winid, 'number', v:false)
  call nvim_win_set_option(winid, 'wrap', v:false)

  let t:any_jump.vim_bufnr = buf

  call t:any_jump.RenderUi()
  call t:any_jump.JumpToFirstOfType('link', 'definitions')
endfu

fu! s:CreateVimUi(internal_buffer) abort
  let l:Filter   = function("s:VimPopupFilter")

  let height = float2nr(&lines * g:any_jump_window_height_ratio)
  let width  = float2nr(&columns * g:any_jump_window_width_ratio)

  let popup_winid = popup_menu([], {
        \"wrap":       0,
        \"cursorline": 1,
        \"minheight":  height,
        \"maxheight":  height,
        \"minwidth":   width,
        \"maxwidth":   width,
        \"border":     [0,0,0,0],
        \"padding":    [0,1,1,1],
        \"filter":     Filter,
        \})

  let a:internal_buffer.popup_winid = popup_winid
  let a:internal_buffer.vim_bufnr   = winbufnr(popup_winid)

  call a:internal_buffer.RenderUi()
  call a:internal_buffer.JumpToFirstOfType('link', 'definitions')
endfu

fu! s:VimPopupFilter(popup_winid, key) abort
  let bufnr = winbufnr(a:popup_winid)
  let ib    = s:GetCurrentInternalBuffer()

  if a:key ==# "j"
    call popup_filter_menu(a:popup_winid, a:key)
    return 1

  elseif a:key ==# "k"
    call popup_filter_menu(a:popup_winid, a:key)
    return 1

  elseif a:key ==# "\<Up>"
    call popup_filter_menu(a:popup_winid, "k")
    return 1

  elseif a:key ==# "\<Down>"
    call popup_filter_menu(a:popup_winid, "j")
    return 1

  elseif a:key ==# "p" || a:key ==# "\<TAB>"
    call g:AnyJumpHandlePreview()
    return 1

  elseif a:key ==# "a"
    call g:AnyJumpLoadNextBatchResults()
    return 1

  elseif a:key ==# "A"
    call g:AnyJumpToggleAllResults()
    return 1

  elseif a:key ==# "r"
    call g:AnyJumpHandleReferences()
    return 1

  elseif a:key ==# "T"
    call g:AnyJumpToggleGrouping()
    return 1

  elseif a:key ==# "L"
    call g:AnyJumpToggleListStyle()
    return 1

  elseif a:key ==# 'b'
    call g:AnyJumpToFirstLink()
    return 1

  elseif a:key ==# "\<CR>" || a:key ==# 'o'
    call g:AnyJumpHandleOpen()
    return 1

  elseif a:key ==# "t"
    call g:AnyJumpHandleOpen('tab')
    return 1

  elseif a:key ==# "s"
    call g:AnyJumpHandleOpen('split')
    return 1

  elseif a:key ==# "v"
    call g:AnyJumpHandleOpen('vsplit')
    return 1

  elseif a:key ==# "q"
        \ || a:key ==# "\<ESC>"
        \ || a:key ==# 'x'
    call g:AnyJumpHandleClose()
    return 1
  endif

  return 1
endfu

fu! s:GetCurrentInternalBuffer() abort
  if exists('t:any_jump')
    return t:any_jump
  else
    throw "any-jump internal buffer lost"
  endif
endfu

fu! s:Jump(...) abort range
  let lang = lang_map#get_language_from_filetype(&l:filetype)
  let keyword = ''

  let opts = {}
  if a:0
    let opts = a:1
  endif

  if has_key(opts, 'is_visual')
    let x = getpos("'<")[2]
    let y = getpos("'>")[2]

    let keyword = getline(line('.'))[ x - 1 : y - 1]
  elseif has_key(opts, 'is_arg')
    let keyword = opts['is_arg']
  else
    let keyword = expand('<cword>')
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

  if g:any_jump_references_enabled || len(ib.definitions_grep_results) == 0
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

let s:available_open_actions = [ 'open', 'split', 'vsplit', 'tab' ]

fu! g:AnyJumpHandleOpen(...) abort
  let ui          = s:GetCurrentInternalBuffer()
  let action_item = ui.GetItemByPos()
  let open_action = 'open'

  if a:0
    let open_action = a:1
  endif

  if index(s:available_open_actions, open_action) == -1
    throw "invalid open action " . string(open_action)
  endif

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

      if open_action == 'open'
      elseif open_action == 'split'
        execute 'split'
      elseif open_action == 'vsplit'
        execute 'vsplit'
      elseif open_action == 'tab'
        execute 'tabnew'
      endif

      " open new file
      execute 'edit ' . action_item.data.path . '|:' . action_item.data.line_number
    endif
  elseif action_item.type == 'more_button'
    call g:AnyJumpLoadNextBatchResults()
  endif
endfu

fu! g:AnyJumpHandleClose() abort
  let ui = s:GetCurrentInternalBuffer()
  let ui.current_page = 1

  if s:nvim
    close!
  else
    call popup_close(ui.popup_winid)
  endif
endfu

fu! g:AnyJumpToggleListStyle() abort
  let ui = s:GetCurrentInternalBuffer()
  let next_style = g:any_jump_results_ui_style == 'filename_first' ?
        \'filename_last' : 'filename_first'

  let g:any_jump_results_ui_style = next_style

  let cursor_item = ui.TryFindOriginalLinkFromPos()
  let last_ln_nr  = ui.BufferLnum()

  call ui.StartUiTransaction()
  call ui.ClearBuffer(ui.vim_bufnr)
  call ui.RenderUi()
  call ui.EndUiTransaction()

  call ui.TryRestoreCursorForItem(cursor_item, {"last_ln_nr": last_ln_nr})
endfu

fu! g:AnyJumpHandleReferences() abort
  let ui = s:GetCurrentInternalBuffer()

  " close current opened usages
  if ui.usages_opened
    let ui.usages_opened = v:false

    let idx            = 0
    let layer_start_ln = 0
    let usages_started = v:false

    call ui.StartUiTransaction()

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

    call ui.EndUiTransaction()
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

  call ui.StartUiTransaction()
  call ui.RenderUiUsagesList(ui.usages_grep_results, start_ln)
  call ui.EndUiTransaction()

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
  let last_ln_nr  = ui.BufferLnum()

  call ui.StartUiTransaction()
  call ui.ClearBuffer(ui.vim_bufnr)

  let ui.preview_opened   = v:false
  let ui.grouping_enabled = ui.grouping_enabled ? v:false : v:true

  call ui.RenderUi()
  call ui.EndUiTransaction()

  if s:nvim
    call ui.TryRestoreCursorForItem(cursor_item, {"last_ln_nr": last_ln_nr})
  else
    call ui.RestorePopupCursor()
  endif
endfu

fu! g:AnyJumpLoadNextBatchResults() abort
  let ui = s:GetCurrentInternalBuffer()

  if ui.overmaxed_results_hidden == v:false
    return
  endif

  let cursor_item = ui.TryFindOriginalLinkFromPos()
  let last_ln_nr  = ui.BufferLnum()

  call ui.StartUiTransaction()
  call ui.ClearBuffer(ui.vim_bufnr)

  let ui.preview_opened = v:false
  let ui.current_page   = ui.current_page ? ui.current_page + 1 : 2

  call ui.RenderUi()
  call ui.EndUiTransaction()

  if s:nvim
    call ui.TryRestoreCursorForItem(cursor_item, {"last_ln_nr": last_ln_nr})
  else
    call ui.RestorePopupCursor()
  endif
endfu

fu! g:AnyJumpToggleAllResults() abort
  let ui = s:GetCurrentInternalBuffer()

  let ui.overmaxed_results_hidden =
        \ ui.overmaxed_results_hidden ? v:false : v:true

  call ui.StartUiTransaction()

  let cursor_item = ui.TryFindOriginalLinkFromPos()
  let last_ln_nr  = ui.BufferLnum()

  call ui.ClearBuffer(ui.vim_bufnr)

  let ui.preview_opened = v:false

  call ui.RenderUi()
  call ui.EndUiTransaction()

  if s:nvim
    call ui.TryRestoreCursorForItem(cursor_item, {"last_ln_nr": last_ln_nr})
  else
    call ui.RestorePopupCursor()
  endif
endfu

fu! g:AnyJumpHandlePreview() abort
  let ui          = s:GetCurrentInternalBuffer()
  let action_item = ui.TryFindOriginalLinkFromPos()

  let preview_actioned_on_self_link = v:false

  " dispatch to other items handler
  if type(action_item) == v:t_dict && action_item.type == 'more_button'
    call g:AnyJumpLoadNextBatchResults()
    return
  endif

  " remove all previews
  if ui.preview_opened
    let ui.preview_opened = v:false

    let idx            = 0
    let layer_start_ln = 0

    call ui.StartUiTransaction()

    for line in ui.items
      if line[0].type == 'preview_text'
        for item in line
          let item.gc = v:true " mark for destroy

          if has_key(item.data, 'link') && item.data.link == action_item
            let preview_actioned_on_self_link = v:true
          endif
        endfor

        let prev_line = ui.items[idx - 1]

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
    call ui.EndUiTransaction()
  endif

  " if clicked on just opened preview
  " then just close, not open again
  " if index(current_previewed_links, action_item) != -1
  if preview_actioned_on_self_link
    return
  endif

  if type(action_item) == v:t_dict
    if action_item.type == 'link' && !has_key(action_item.data, "group_header")
      call ui.StartUiTransaction()

      let ui.preview_opened = v:true

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
          let first_kw_pos = match(cur_text, '\<' . ui.keyword . '\>')

          while cur_text != ''
            if first_kw_pos == 0
              let cur_kw = ui.CreateItem("preview_text",
                    \ cur_text[first_kw_pos : first_kw_pos + len(ui.keyword) - 1],
                    \ g:AnyJumpGetColor("preview_keyword"),
                    \ { "link": action_item, "no_padding": v:true })

              call add(items, cur_kw)
              let cur_text = cur_text[first_kw_pos + len(ui.keyword) : -1]

            elseif first_kw_pos == -1
              let tail = cur_text
              let item = ui.CreateItem("preview_text", tail, g:AnyJumpGetColor('preview'), { "link": action_item, "no_padding": v:true })

              call add(items, item)
              let cur_text = ''

            else
              let head = cur_text[0 : first_kw_pos - 1]
              let head_item = ui.CreateItem("preview_text", head, g:AnyJumpGetColor('preview'), { "link": action_item, "no_padding": v:true })

              call add(items, head_item)

              let cur_kw = ui.CreateItem("preview_text",
                    \ cur_text[first_kw_pos : first_kw_pos + len(ui.keyword) -1 ],
                    \ g:AnyJumpGetColor("preview_keyword"),
                    \ { "link": action_item, "no_padding": v:true })

              call add(items, cur_kw)

              let cur_text = cur_text[first_kw_pos + len(ui.keyword) : -1]
            endif

            let first_kw_pos = match(cur_text, '\<' . ui.keyword . '\>')
          endwhile
        else
          let items = [ ui.CreateItem("preview_text", line, g:AnyJumpGetColor('preview'), { "link": action_item } ) ]
        endif

        call ui.AddLineAt(items, render_ln + 1)

        let render_ln += 1
      endfor

      call ui.EndUiTransaction()

    elseif action_item.type == 'help_link'
    endif
  endif

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
command! -range AnyJumpVisual call s:Jump({"is_visual": v:true})
command! -nargs=1 AnyJumpArg call s:Jump({"is_arg": <f-args>})
command! AnyJumpBack call s:JumpBack()
command! AnyJumpLastResults call s:JumpLastResults()
command! AnyJumpRunSpecs call s:RunSpecs()

" Window KeyBindings
if s:nvim
  augroup anyjump
    au!
    au FileType any-jump nnoremap <buffer> o :call g:AnyJumpHandleOpen()<cr>
    au FileType any-jump nnoremap <buffer><CR> :call g:AnyJumpHandleOpen()<cr>
    au FileType any-jump nnoremap <buffer> t :call g:AnyJumpHandleOpen('tab')<cr>
    au FileType any-jump nnoremap <buffer> s :call g:AnyJumpHandleOpen('split')<cr>
    au FileType any-jump nnoremap <buffer> v :call g:AnyJumpHandleOpen('vsplit')<cr>

    au FileType any-jump nnoremap <buffer> p :call g:AnyJumpHandlePreview()<cr>
    au FileType any-jump nnoremap <buffer> <tab> :call g:AnyJumpHandlePreview()<cr>
    au FileType any-jump nnoremap <buffer> q :call g:AnyJumpHandleClose()<cr>
    au FileType any-jump nnoremap <buffer> <esc> :call g:AnyJumpHandleClose()<cr>
    au FileType any-jump nnoremap <buffer> r :call g:AnyJumpHandleReferences()<cr>
    au FileType any-jump nnoremap <buffer> b :call g:AnyJumpToFirstLink()<cr>
    au FileType any-jump nnoremap <buffer> T :call g:AnyJumpToggleGrouping()<cr>
    au FileType any-jump nnoremap <buffer> A :call g:AnyJumpToggleAllResults()<cr>
    au FileType any-jump nnoremap <buffer> a :call g:AnyJumpLoadNextBatchResults()<cr>
    au FileType any-jump nnoremap <buffer> L :call g:AnyJumpToggleListStyle()<cr>
  augroup END
end

if g:any_jump_disable_default_keybindings == v:false
  nnoremap <leader>j  :AnyJump<CR>
  xnoremap <leader>j  :AnyJumpVisual<CR>
  nnoremap <leader>ab :AnyJumpBack<CR>
  nnoremap <leader>al :AnyJumpLastResults<CR>
end
