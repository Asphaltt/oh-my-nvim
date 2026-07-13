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
