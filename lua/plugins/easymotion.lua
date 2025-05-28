return {
	"easymotion/vim-easymotion",
	config = function()
		vim.cmd([[
source $HOME/.config/nvim/vim/easymotion/plugin/EasyMotion.vim

let g:EasyMotion_smartcase = 1

map <Leader><Leader>h <Plug>(easymotion-lineback)
map <Leader><Leader>j <Plug>(easymotion-j)
map <Leader><Leader>k <Plug>(easymotion-k)
map <Leader><Leader>l <Plug>(easymotion-lineforward)

map <Leader><Leader>. <Plug>(easymotion-repeat)
        ]])
	end,
}
