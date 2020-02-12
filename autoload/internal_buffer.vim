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
let s:InternalBuffer = {}

let s:InternalBuffer.MethodsList = [
      \'RenderLine',
      \'AddLine',
      \'AddLineAt',
      \'CreateItem',
      \'len',
      \'GetItemByPos',
      \'GetItemLineNumber',
      \'GetFirstItemOfType',
      \'RenderUiUsagesList',
      \'RenderUiDefinitionsList',
      \'RenderUiStartScreen',
      \'StartUiTransaction',
      \'EndUiTransaction',
      \'ConvertGrepResultToItems',
      \'RemoveLines',
      \'RemoveGarbagedLines',
      \]

" Produce new Render Buffer
fu! s:InternalBuffer.New() abort
  let object = {
        \"items":          [],
        \"gc":             v:false,
        \"preview_opened": v:false,
        \"usages_opened":  v:false,
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

  call appendbufline(bufnr(), a:line, text)

  for region in hl_regions
    call nvim_buf_add_highlight(
          \bufnr(),
          \-1,
          \region[0],
          \a:line,
          \region[1],
          \region[2])
  endfor
endfu

fu! s:InternalBuffer.AddLine(items) dict abort
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

fu! s:InternalBuffer.AddLineAt(items, line_number) dict abort
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
fu! s:InternalBuffer.CreateItem(type, text, start_col, end_col, hl_group, ...) dict abort
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


fu! s:InternalBuffer.GetItemByPos() dict abort
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
" COMPLEXITY: O(1)
fu! s:InternalBuffer.GetItemLineNumber(item) dict abort
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

fu! s:InternalBuffer.GetFirstItemOfType(type) dict abort
  let result = 0

  for line in self.items
    for item in line
      if item.type == a:type
        let result = item
        break
      endif
    endfor
  endfor

  return result
endfu

fu! s:InternalBuffer.StartUiTransaction(buf) dict abort
  call nvim_buf_set_option(a:buf, 'modifiable', v:true)
endfu

fu! s:InternalBuffer.EndUiTransaction(buf) dict abort
  call nvim_buf_set_option(a:buf, 'modifiable', v:false)
endfu

fu! s:InternalBuffer.ConvertGrepResultToItems(gr, current_idx, layer) dict abort
  let gr    = a:gr
  let items = []

  if g:any_jump_definitions_results_list_style == 1
    let path_text = ' ' .  gr.path .  ":" . gr.line_number

    let prefix = self.CreateItem("link", (a:current_idx + 1 . " "), 0, -1, "Comment",
          \{"path": gr.path, "line_number": gr.line_number, "layer": a:layer})

    let matched_text = self.CreateItem("link", gr.text, 0, -1, "Statement",
          \{"path": gr.path, "line_number": gr.line_number, "layer": a:layer})

    let file_path = self.CreateItem("link", path_text, 0, -1, "String",
          \{"path": gr.path, "line_number": gr.line_number, "layer": a:layer})

    let items = [ prefix, matched_text, file_path ]

  elseif g:any_jump_definitions_results_list_style == 2
    let path_text = gr.path .  ":" . gr.line_number

    let matched_text = self.CreateItem("link", " " . gr.text, 0, -1, "Statement",
          \{"path": gr.path, "line_number": gr.line_number, "layer": a:layer})

    let file_path = self.CreateItem("link", path_text, 0, -1, "String",
          \{"path": gr.path, "line_number": gr.line_number, "layer": a:layer})

    let items = [ file_path, matched_text ]
  endif

  return items
endfu

fu! s:InternalBuffer.RenderUiUsagesList(grep_results, start_ln) dict abort
  if !has_key(self, 'usages_grep_results')
    return
  endif

  let start_ln = a:start_ln

  call self.AddLineAt([ self.CreateItem("text", "> Usages", 0, -1, "Comment", {"layer": "usages"}) ], start_ln)
  let start_ln += 1

  call self.AddLineAt([ self.CreateItem("text", "", 0, -1, "Comment", {"layer": "usages"}) ], start_ln)
  let start_ln += 1

  call self.AddLineAt([ self.CreateItem("text", " ", 0, -1, "Comment", {"layer": "usages"}) ], start_ln)

  " draw grep results
  let idx = 0

  for gr in self.usages_grep_results
    let items = self.ConvertGrepResultToItems(gr, idx, "usages")
    call self.AddLineAt(items, start_ln)

    let idx += 1
    let start_ln += 1
  endfor

  return v:true
endfu

fu! s:InternalBuffer.RenderUiStartScreen() dict abort
  if !has_key(self, 'definitions_grep_results')
    return
  endif

  " move ui drawing to method?
  call self.AddLine([ self.CreateItem("text", "", 0, -1, "Comment") ])

  call self.AddLine([
    \self.CreateItem("text", ">", 0, 2, "Comment"),
    \self.CreateItem("text", self.keyword, 1, -1, "Identifier"),
    \self.CreateItem("text", "definitions", 1, -1, "Comment"),
    \])

  call self.AddLine([ self.CreateItem("text", "", 0, -1, "Comment") ])


  " draw grep results
  let idx        = 0
  let first_item = 0
  let insert_ln = self.len()

  for gr in self.definitions_grep_results
    let items = self.ConvertGrepResultToItems(gr, idx, "definitions")
    call self.AddLineAt(items, insert_ln)

    if idx == 0
      let first_item = items[0]
    endif

    let idx += 1
    let insert_ln += 1
  endfor

  let first_item_ln = self.GetItemLineNumber(first_item)
  call cursor(first_item_ln, 2)

  call self.AddLine([ self.CreateItem("text", "", 0, -1, "Comment") ])

  call self.AddLine([ self.CreateItem("help_link", "> Help", 0, -1, "Comment") ])

  call self.AddLine([ self.CreateItem("help_text", "", 0, -1, "Comment") ])
  call self.AddLine([ self.CreateItem("help_text", "[o/enter] open file   [tab/p] preview file   [u] find usages ", 0, -1, "String") ])
  call self.AddLine([ self.CreateItem("help_text", "", 0, -1, "Comment") ])

  " call self.AddLine([ self.CreateItem("button", "[s] save search   [S] clean search   [N] next saved   [P] previous saved", 0, -1, "Identifier") ])

  call nvim_buf_set_option(bufnr(), 'modifiable', v:false)
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

fu! s:InternalBuffer.RenderUiDefinitionsList(grep_results, start_ln) dict abort
endfu

fu! s:InternalBuffer.RemoveLines(line_from, line_to) dict abort
endfu

" Public api
fu! internal_buffer#GetClass() abort
  return s:InternalBuffer
endfu
