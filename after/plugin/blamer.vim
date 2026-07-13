function! blamer#EnableShow() abort
  if get(g:, 'blamer_enabled', 0) == 0 || get(g:, 'blamer_async_buffer_enabled', 0) == 0 || get(g:, 'blamer_async_show_enabled', 0) == 1
    return
  endif

  let g:blamer_async_show_enabled = 1
  call s:ScheduleBlamerShow(get(g:, 'blamer_open_delay', 1000))
endfunction

function! blamer#DisableShow() abort
  if get(g:, 'blamer_enabled', 0) == 0 || get(g:, 'blamer_async_buffer_enabled', 0) == 0 || get(g:, 'blamer_async_show_enabled', 0) == 0
    return
  endif

  let g:blamer_async_show_enabled = 0
  call s:StopBlamerTimer()
  call blamer#Hide()
endfunction

function! blamer#Refresh() abort
  if get(g:, 'blamer_enabled', 0) == 0 || get(g:, 'blamer_async_buffer_enabled', 0) == 0 || get(g:, 'blamer_async_show_enabled', 0) == 0
    return
  endif

  call blamer#Hide()
  if get(g:, 'blamer_async_entering_buffer', 0)
    let g:blamer_async_entering_buffer = 0
    call s:ScheduleBlamerShow(get(g:, 'blamer_open_delay', 1000))
  else
    call s:ScheduleBlamerShow(get(g:, 'blamer_delay', 100))
  endif
endfunction

function! blamer#BufferEnter() abort
  if get(g:, 'blamer_enabled', 0) == 0
    return
  endif

  if blamer#IsBufferGitTracked()
    let g:blamer_async_buffer_enabled = 1
    let g:blamer_async_entering_buffer = 1
    call blamer#UpdateGitUserConfig()
    call blamer#EnableShow()
  else
    let g:blamer_async_buffer_enabled = 0
  endif
endfunction

function! blamer#BufferLeave() abort
  if get(g:, 'blamer_enabled', 0) == 0
    return
  endif

  call blamer#DisableShow()
endfunction

function! blamer#Enable() abort
  let g:blamer_enabled = 1
  let g:blamer_async_buffer_enabled = blamer#IsBufferGitTracked()
endfunction

function! blamer#Disable() abort
	let g:blamer_enabled = 0
	let g:blamer_async_buffer_enabled = 0
	let g:blamer_async_show_enabled = 0
	call s:StopBlamerTimer()
	call blamer#Hide()
endfunction

function! blamer#Show() abort
	if get(g:, 'blamer_enabled', 0) == 0 || &buftype !=# ''
		return
	endif

	let l:file_path = expand('%:p')
	if empty(l:file_path)
		return
	endif

	let l:buffer_number = bufnr('')
	let l:line_numbers = s:GetLines()
	if len(l:line_numbers) > 1 && get(g:, 'blamer_show_in_visual_modes', 1) == 0
		return
	endif

	let g:blamer_async_request_id = get(g:, 'blamer_async_request_id', 0) + 1
	let l:request_id = g:blamer_async_request_id
	let l:start_line = l:line_numbers[0]
	let l:end_line = l:start_line + len(l:line_numbers) - 1
	let l:cmd = [
		\ 'git',
		\ '-C',
		\ fnamemodify(l:file_path, ':h'),
		\ '--no-pager',
		\ 'blame',
		\ '--line-porcelain',
		\ '-L',
		\ l:start_line . ',' . l:end_line,
		\ '--',
		\ l:file_path,
		\ ]

	call jobstart(l:cmd, {
		\ 'stdout_buffered': v:true,
		\ 'stderr_buffered': v:true,
		\ 'on_stdout': function('s:OnBlamerStdout', [l:request_id, l:buffer_number, l:line_numbers]),
		\ })
endfunction

function! s:ScheduleBlamerShow(delay) abort
  call s:StopBlamerTimer()
  let g:blamer_async_timer_id = timer_start(a:delay, { tid -> blamer#Show() })
endfunction

function! s:StopBlamerTimer() abort
	if get(g:, 'blamer_async_timer_id', -1) == -1
		return
	endif

	call timer_stop(g:blamer_async_timer_id)
	let g:blamer_async_timer_id = -1
endfunction

function! s:GetLines() abort
	let l:visual_line_number = line('v')
	let l:cursor_line_number = line('.')

	if l:visual_line_number < l:cursor_line_number
		return range(l:visual_line_number, l:cursor_line_number)
	elseif l:cursor_line_number < l:visual_line_number
		return range(l:cursor_line_number, l:visual_line_number)
	else
		return [l:cursor_line_number]
	endif
endfunction

function! s:OnBlamerStdout(request_id, buffer_number, line_numbers, _job_id, data, _event) abort
	if a:request_id != get(g:, 'blamer_async_request_id', 0)
		return
	endif

	if !bufexists(a:buffer_number)
		return
	endif

	let l:messages = s:MessagesFromPorcelain(a:data)
	if empty(l:messages)
		return
	endif

	let l:index = 0
	for line_number in a:line_numbers
		if l:index >= len(l:messages)
			break
		endif

		call blamer#SetVirtualText(a:buffer_number, line_number, l:messages[l:index])
		let l:index += 1
	endfor
endfunction

function! s:MessagesFromPorcelain(lines) abort
	let l:TAB_ASCII = 9
	let l:commit_data = {}
	let l:commit_data_per_line = []

	for line in a:lines
		if empty(line)
			continue
		endif

		let l:line_words = split(line, ' ')
		if empty(l:line_words)
			continue
		endif

		let l:is_line_hash = !empty(matchstr(l:line_words[0], '\c[0-9a-f]\{40}'))
		let l:has_line_tab = char2nr(l:line_words[0][0]) == l:TAB_ASCII

		if l:is_line_hash
			let l:commit_data = {
				\ 'commit-short': l:line_words[0][:7],
				\ 'commit-long': l:line_words[0],
				\ }
		elseif l:has_line_tab
			if get(l:commit_data, 'author', '') ==? 'Not Committed Yet'
				let l:commit_data.author = 'You'
				let l:commit_data.committer = 'You'
				let l:commit_data.summary = 'Uncommitted changes'
			endif
			call add(l:commit_data_per_line, extend({}, l:commit_data))
		else
			let l:commit_data = extend(l:commit_data, blamer#ParseCommitDataLine(line))
		endif
	endfor

	return map(l:commit_data_per_line, 'blamer#CommitDataToMessage(v:val)')
endfunction
