"Plugins
set nocompatible              " be iMproved, required
filetype off                  " required

"set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
"Plugins to be added from here
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
"All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
"Plugins

"Basic Configuration
set number
set incsearch
set hlsearch

nnoremap j h
nnoremap k j
nnoremap l k
nnoremap ; l
nnoremap t <C-t>
nnoremap T <C-T>
nnoremap t gt
nnoremap T gT
inoremap <C-h> <ESC>
nmap <C-f> :NERDTreeToggle<CR>
"Basic Configuration

"Linux-specific config acc to KernelNewbies
syntax on
set title
set tabstop=8
set softtabstop=8
set shiftwidth=8
set noexpandtab
"Linux-specific config acc to KernelNewbies

"Cursors
let &t_SI = "\<esc>[5 q"  " blinking I-beam in insert mode
let &t_SR = "\<esc>[3 q"  " blinking underline in replace mode
let &t_EI = "\<esc>[ q"  " default cursor (usually blinking block) otherwise
"Cursors

"OLD STUFF
"set colorcolumn=80
"highlight ColorColumn ctermbg=lightgrey guibg=lightgrey
set textwidth=80
"set background=dark

"set colorcolumn=80
"highlight ColorColumn ctermbg=lightgrey guibg=lightgrey
"set textwidth=80
"set background=dark
