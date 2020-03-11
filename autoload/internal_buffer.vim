" ----------------------------------------------
" Internal buffer prototype definition
" ----------------------------------------------
" represents ui internal structure

" abstract structure of internal buffer representation:
"
" buffer = [ array of lines ]
"
" line = [ list of items
"   { type, strat_col, finish_col, text, hl_group },
"   { ... },
"   ...
" ]

let s:nvim = has('nvim')

let s:InternalBuffer = {}

let s:InternalBuffer.MethodsList = [
      \'RenderLine',
      \'AddLine',
      \'AddLineAt',
      \'CreateItem',
      \'len',
      \'GetItemByPos',
      \'GetItemLineNumber',
      \'GetItemLineNumberByData',
      \'GetFirstItemOfType',
      \'TryFindOriginalLinkFromPos',
      \'TryRestoreCursorForItem',
      \'RenderUiUsagesList',
      \'RenderUi',
      \'StartUiTransaction',
      \'EndUiTransaction',
      \'GrepResultToItems',
      \'GrepResultToGroupedItems',
      \'RemoveGarbagedLines',
      \'JumpToFirstOfType',
      \'ClearBuffer',
      \'BufferLnum',
      \'RestorePopupCursor',
      \]

" Produce new Render Buffer
fu! s:InternalBuffer.New() abort
  let object = {
        \"items":                    [],
        \"current_page":             0,
        \"gc":                       v:false,
        \"preview_opened":           v:false,
        \"usages_opened":            v:false,
        \"grouping_enabled":         v:false,
        \"overmaxed_results_hidden": v:true,
        \"definitions_grep_results": [],
        \"usages_grep_results":      [],
        \"vim_bufnr":                0,
        \"popup_winid":              0,
        \"previous_bufnr":           0,
        \}

  for method in self.MethodsList
    let object[method] = s:InternalBuffer[method]
  endfor

  return object
endfu

fu! s:InternalBuffer.len() dict abort
  return len(self.items)
endfu

fu! s:InternalBuffer.RenderLine(items, line) dict abort
  let text           = s:nvim ? " " : ""
  let idx            = 0
  let next_start_col = 1

  " calculate & assign items start & end columns
  for item in a:items
    " separate items in line with 1 space
    if idx == 0
      let text = text . item.text
    else
      if has_key(item.data, 'no_padding')
        let text = text . item.text
      else
        let text = text . ' ' . item.text
        let next_start_col = next_start_col + 1
      endif
    endif

    let item.start_col = next_start_col
    let item.end_col   = next_start_col + len(item.text)

    let next_start_col  = item.end_col
    let idx            += 1
  endfor

  " filter out empty whitespaces
  if text =~ '^\s\+$'
    let text = ''
  endif

  " write final text to buffer
  call appendbufline(self.vim_bufnr, a:line - 1, text)

  " colorize
  for item in a:items
    if s:nvim
      call nvim_buf_add_highlight(
            \self.vim_bufnr,
            \-1,
            \item.hl_group,
            \a:line - 1,
            \item.start_col,
            \item.end_col)
    else
      call prop_add(a:line, item.start_col, {
            \'length': item.len,
            \'type': item.hl_group,
            \'bufnr': self.vim_bufnr})
    endif
  endfor
endfu

fu! s:InternalBuffer.AddLine(items) dict abort
  if type(a:items) == v:t_list
    call self.RenderLine(a:items, self.len() + 1)
    call add(self.items, a:items)

    return v:true
  else
    echoe "array required, got invalid type: " . string(a:items)

    return v:false
  endif
endfu

fu! s:InternalBuffer.AddLineAt(items, line_number) dict abort
  if type(a:items) == v:t_list
    call self.RenderLine(a:items, a:line_number)
    call insert(self.items, a:items, a:line_number - 1)

    return v:true
  else
    echoe "array required, got invalid type: " . string(a:items)

    return v:false
  endif
endfu

" type:
"   'text' / 'link' / 'button' / 'preview_text'
fu! s:InternalBuffer.CreateItem(type, text, hl_group, ...) dict abort
  let data = {}

  if a:0
    let data = a:1
  endif

  let item = {
        \"type":      a:type,
        \"text":      a:text,
        \"len":       len(a:text),
        \"start_col": 0,
        \"end_col":   0,
        \"hl_group":  a:hl_group,
        \"gc":        v:false,
        \"data":      data
        \}

  " TODO: optimize this part for rednering perfomance
  if !s:nvim
    if prop_type_get(item.hl_group, {'bufnr': self.vim_bufnr}) == {}
      call prop_type_add(item.hl_group, {
            \'highlight': item.hl_group,
            \'bufnr': self.vim_bufnr
            \})
    endif
  endif

  return item
endfu


fu! s:InternalBuffer.GetItemByPos() dict abort
  if s:nvim
    let idx = getbufinfo(self.vim_bufnr)[0]['lnum']
  else
    " vim popup buffer doesn't have current line info inside getbufinfo()
    " so extract line nr from win
    let l:popup_pos = 0
    call win_execute(self.popup_winid, 'let l:popup_pos = getcurpos()')
    let idx = l:popup_pos[1]
  end

  if idx > len(self.items)
    return 0
  endif

  if s:nvim
    let column = col('.')
  else
    let column = 1
  end

  let line = self.items[idx - 1]

  for item in line
    if item.start_col <= column && (item.end_col >= column || item.end_col == -1 )
      return item
    endif
  endfor

  return 0
endfu

" not optimal, but ok for current ui with around ~100/200 lines
" COMPLEXITY: O(1)
fu! s:InternalBuffer.GetItemLineNumber(item) dict abort
  let i = 0
  let found = 0

  for line in self.items
    let i += 1

    for item in line
      if item == a:item
        let found = i
        break
      endif
    endfor

    if found > 0
      break
    endif
  endfor

  return found
endfu

" not optimal, but ok for current ui with around ~100/200 lines
" COMPLEXITY: O(1)
fu! s:InternalBuffer.GetItemLineNumberByData(data) dict abort
  let i = 0
  let found = 0

  for line in self.items
    let i += 1

    for item in line
      if item.data == a:data
        let found = i
        break
      endif
    endfor

    if found > 0
      break
    endif
  endfor

  return found
endfu

fu! s:InternalBuffer.GetFirstItemOfType(type, ...) dict abort
  let result = 0
  let layer  = 0

  if a:0 == 1
    let layer = a:1
  endif

  for line in self.items
    if type(result) == v:t_dict
      break
    endif

    for item in line
      let type_is_ok  = item.type == a:type
      let layer_is_ok = v:true

      if type(layer) == v:t_string
        let layer_is_ok = item.data.layer == layer
      endif

      if type_is_ok && layer_is_ok
        let result = item
        break
      endif
    endfor
  endfor

  return result
endfu

fu! s:InternalBuffer.TryFindOriginalLinkFromPos() dict abort
  let cursor_item = self.GetItemByPos()

  " try to find original link
  if type(cursor_item) == v:t_dict && type(cursor_item.data) == v:t_dict
        \ && cursor_item.type == 'link'
        \ && !has_key(cursor_item, 'original_link')
    let ln   = self.GetItemLineNumber(cursor_item)
    let line = self.items[ln - 1]

    for item in line
      if type(item.data) == v:t_dict && has_key(item.data, 'original_link')
        let cursor_item = item
        break
      endif
    endfor
  endif

  return cursor_item
endfu

fu! s:InternalBuffer.TryRestoreCursorForItem(item,...) dict abort
  let opts = {}
  if a:0 == 1 && type(a:1) == v:t_dict
    let opts = a:1
  endif

  if type(a:item) == v:t_dict
        \ && a:item.type == "link"
        \ && !has_key(a:item.data, 'group_header')

      let new_ln = self.GetItemLineNumberByData(a:item.data)

      " item removed
      if new_ln == 0
        call self.JumpToFirstOfType('link')
      else
        call cursor(new_ln, 2)
      endif
  else
    if has_key(opts, 'last_ln_nr')
      if opts.last_ln_nr > self.len()
        call self.JumpToFirstOfType('link')
      else
        call cursor(opts.last_ln_nr, 2)
        call cursor(opts.last_ln_nr, 2)
      endif
    else
      call self.JumpToFirstOfType('link')
    endif
  endif
endfu

fu! s:InternalBuffer.JumpToFirstOfType(type, ...) dict abort
  let item = self.GetFirstItemOfType(a:type, a:000)

  if type(item) == v:t_dict
    let ln = self.GetItemLineNumber(item)
    call cursor(ln, 2)
  endif
endfu

fu! s:InternalBuffer.ClearBuffer(buf) dict abort
  call deletebufline(a:buf, 1, self.len() + 1)
endfu

fu! s:InternalBuffer.BufferLnum() dict abort
  return getbufinfo(self.vim_bufnr)[0]['lnum']
endfu

fu! s:InternalBuffer.RestorePopupCursor() dict abort
  if !s:nvim
    call popup_filter_menu(self.popup_winid, 'j')
  endif
endfu

fu! s:InternalBuffer.StartUiTransaction() dict abort
  if !s:nvim
    return
  endif

  call setbufvar(self.vim_bufnr, '&modifiable', 1)
endfu

fu! s:InternalBuffer.EndUiTransaction() dict abort
  if !s:nvim
    return
  endif

  call setbufvar(self.vim_bufnr, '&modifiable', 0)
endfu

fu! s:InternalBuffer.GrepResultToItems(gr, current_idx, layer) dict abort
  let gr    = a:gr
  let items = []

  let options =
        \{ "path": gr.path, "line_number": gr.line_number, "layer": a:layer }
  let original_link_options =
        \{ "path": gr.path, "line_number": gr.line_number,
        \"layer": a:layer, "original_link": v:true }

  if g:any_jump_list_numbers
    let prefix_text = a:current_idx + 1
    let prefix = self.CreateItem("link", prefix_text, g:AnyJumpGetColor('result_line_number'), options)

    call add(items, prefix)
  endif

  if g:any_jump_results_ui_style == 'filename_first'
    let path_text    = gr.path .  ":" . gr.line_number
    let matched_text = self.CreateItem("link", "" . gr.text, g:AnyJumpGetColor('result_text'), original_link_options)
    let file_path    = self.CreateItem("link", path_text, g:AnyJumpGetColor('result_path'), options)

    call add(items, file_path)
    call add(items, matched_text)
  elseif g:any_jump_results_ui_style == 'filename_last'
    let path_text    = '' .  gr.path .  ":" . gr.line_number
    let matched_text = self.CreateItem("link", gr.text, g:AnyJumpGetColor('result_text'), original_link_options)
    let file_path    = self.CreateItem("link", path_text, g:AnyJumpGetColor('result_path'), options)

    call add(items, matched_text)
    call add(items, file_path)
  endif

  return items
endfu

fu! s:InternalBuffer.GrepResultToGroupedItems(gr, current_idx, layer) dict abort
  let gr      = a:gr
  let items   = []

  let options =
        \{ "path": gr.path, "line_number": gr.line_number, "layer": a:layer }
  let original_link_options =
        \{ "path": gr.path, "line_number": gr.line_number,
        \"layer": a:layer, "original_link": v:true }

  let prefix_text = gr.line_number
  let prefix = self.CreateItem("link", prefix_text, g:AnyJumpGetColor('result_line_number'), options)

  call add(items, prefix)

  let matched_text = self.CreateItem("link", gr.text, g:AnyJumpGetColor('result_text'), original_link_options)

  call add(items, matched_text)

  return items
endfu

fu! s:InternalBuffer.RenderUiUsagesList(grep_results, start_ln) dict abort
  let start_ln     = a:start_ln
  let hidden_count = 0

  " TODO: move to method
  if type(g:any_jump_max_search_results) == v:t_number
        \ && g:any_jump_max_search_results > 0
        \ && self.overmaxed_results_hidden == v:true

    let cp = self.current_page ? self.current_page : 1
    let to = (cp * g:any_jump_max_search_results) - 1

    let collection   = self.usages_grep_results[0 : to]
    let hidden_count = len(self.usages_grep_results[to : -1])
  else
    let collection = self.usages_grep_results
  endif

  call self.AddLineAt([
    \self.CreateItem("text", ">", g:AnyJumpGetColor('heading_text'), {'layer': 'usages'}),
    \self.CreateItem("text", self.keyword, g:AnyJumpGetColor('heading_keyword'), {'layer': 'usages'}),
    \self.CreateItem("text", len(self.usages_grep_results) . " references", g:AnyJumpGetColor('heading_text'), {'layer': 'usages'}),
    \], start_ln)


  let start_ln += 1

  call self.AddLineAt([ self.CreateItem("text", "", "Comment", {"layer": "usages"}) ], start_ln)

  let start_ln += 1

  let idx = 0
  if self.grouping_enabled
    " group by file name rendering
    let render_map = {}

    for gr in collection
      if !has_key(render_map, gr.path)
        let render_map[gr.path] = []
      endif

      call add(render_map[gr.path], gr)
    endfor

    let path_idx = 0
    for path in keys(render_map)
      let first_gr = render_map[path][0]
      let opts     = {
            \"path":         path,
            \"line_number":  first_gr.line_number,
            \"layer":        "usages",
            \"group_header": v:true,
            \}

      let prefix     = self.CreateItem("link", ">", g:AnyJumpGetColor('group_text'), opts)
      let group_name = self.CreateItem("link", path, g:AnyJumpGetColor('group_name'), opts)
      let line       = [ prefix, group_name ]

      call self.AddLineAt(line, start_ln)
      let start_ln += 1

      for gr in render_map[path]
        let items = self.GrepResultToGroupedItems(gr, idx, "usages")
        call self.AddLineAt(items, start_ln)

        let start_ln += 1
        let idx += 1
      endfor

      if path_idx != len(keys(render_map)) - 1
        call self.AddLineAt([ self.CreateItem("text", "", "Comment", {"layer": "usages"}) ], start_ln)

        let start_ln += 1
      endif

      let path_idx += 1
    endfor
  else
    for gr in collection
      let items = self.GrepResultToItems(gr, idx, "usages")
      call self.AddLineAt(items, start_ln)

      let idx += 1
      let start_ln += 1
    endfor
  endif

  if hidden_count > 0
    call self.AddLineAt([ self.CreateItem("text", "", "Comment", {"layer": "usages"}) ], start_ln)
    let start_ln += 1

    call self.AddLineAt([
          \self.CreateItem("more_button", '[ ' . hidden_count . ' more ]', g:AnyJumpGetColor('more_button'), {"layer": "usages"}),
          \self.CreateItem("more_button", '— [a] load more results [A] load all', g:AnyJumpGetColor('more_explain'), {"layer": "usages"}),
          \], start_ln)
    let start_ln += 1
  endif

  call self.AddLineAt([ self.CreateItem("text", " ", "Comment", {"layer": "usages"}) ], start_ln)

  return v:true
endfu

fu! s:InternalBuffer.RenderUi() dict abort
  " clear items before render
  let self.items = []

  call self.AddLine([ self.CreateItem("text", "", "Comment") ])

  call self.AddLine([
    \self.CreateItem("text", ">", g:AnyJumpGetColor('heading_text')),
    \self.CreateItem("text", self.keyword, g:AnyJumpGetColor('heading_keyword')),
    \self.CreateItem("text", len(self.definitions_grep_results) . " definitions", g:AnyJumpGetColor('heading_text')),
    \])

  call self.AddLine([ self.CreateItem("text", "", "Comment") ])

  " draw grep results
  let idx          = 0
  let hidden_count = 0

  " TODO: move to method
  if type(g:any_jump_max_search_results) == v:t_number
        \ && g:any_jump_max_search_results > 0
        \ && self.overmaxed_results_hidden == v:true

    let cp = self.current_page ? self.current_page : 1
    let to = (cp * g:any_jump_max_search_results) - 1

    let collection   = self.definitions_grep_results[0 : to]
    let hidden_count = len(self.definitions_grep_results[to : -1])
  else
    let collection = self.definitions_grep_results
  endif

  if self.grouping_enabled
    " group by file name rendering
    let render_map = {}

    for gr in collection
      if !has_key(render_map, gr.path)
        let render_map[gr.path] = []
      endif

      call add(render_map[gr.path], gr)
    endfor

    let path_idx = 0

    for path in keys(render_map)
      let first_gr = render_map[path][0]
      let opts     = {
            \"path":         path,
            \"line_number":  first_gr.line_number,
            \"layer":        "definitions",
            \"group_header": v:true,
            \}

      let prefix     = self.CreateItem("link", ">", g:AnyJumpGetColor('group_text'), opts)
      let group_name = self.CreateItem("link", path, g:AnyJumpGetColor('group_name'), opts)
      let line       = [ prefix, group_name ]

      call self.AddLine(line)

      for gr in render_map[path]
        let items = self.GrepResultToGroupedItems(gr, idx, "definitions")
        call self.AddLine(items)

        let idx += 1
      endfor

      if path_idx != len(keys(render_map)) - 1
         call self.AddLine([ self.CreateItem("text", "", "Comment") ])
      endif

      let path_idx += 1
    endfor

    call self.AddLine([ self.CreateItem("text", "", "Comment") ])
  else
    if len(collection)
      for gr in collection
        let items = self.GrepResultToItems(gr, idx, "definitions")
        call self.AddLine(items)

        let idx += 1
      endfor
    else
      call self.AddLine([ self.CreateItem("text", "No definitions results", g:AnyJumpGetColor('plain_text')) ])
    endif

    call self.AddLine([ self.CreateItem("text", "", "Comment") ])
  endif

  if hidden_count > 0
    call self.AddLine([
          \self.CreateItem("more_button", '[ + ' . hidden_count . ' more ]', g:AnyJumpGetColor('more_button')),
          \self.CreateItem("more_button", '— [a] load more results [A] load all', g:AnyJumpGetColor('more_explain')),
          \])
    call self.AddLine([ self.CreateItem("text", "", "Comment") ])
  endif

  if self.usages_opened && len(self.usages_grep_results) > 0
    call self.RenderUiUsagesList(self.usages_grep_results, self.len() + 1)
  endif

  call self.AddLine([ self.CreateItem("help_link", "> Help", g:AnyJumpGetColor('heading_text')) ])

  let color = g:AnyJumpGetColor('help')

  call self.AddLine([ self.CreateItem("help_text", "", color) ])
  call self.AddLine([ self.CreateItem("help_text", "[o] open               [t] open in tab        [s] open in split   [v] open in vsplit", color) ])
  call self.AddLine([ self.CreateItem("help_text", "[p/tab] preview file   [b] scroll to first result", color) ])
  call self.AddLine([ self.CreateItem("help_text", "[a] load more results  [A] load all results", color) ])
  call self.AddLine([ self.CreateItem("help_text", "[r] show references    [T] group by file", color) ])
  call self.AddLine([ self.CreateItem("help_text", "[L] toggle search                             [esc/q] exit", color) ])
  call self.AddLine([ self.CreateItem("help_text", "    results ui style", color) ])
endfu

fu! s:InternalBuffer.RemoveGarbagedLines() dict abort
  " remove marked for garbage collection lines
  let new_items = []

  for line in self.items
    if has_key(line[0], 'gc') == v:false || line[0].gc == v:false
      call add(new_items, line)
    endif
  endfor

  let self.items = new_items
endfu


" Public api
fu! internal_buffer#GetClass() abort
  return s:InternalBuffer
endfu
