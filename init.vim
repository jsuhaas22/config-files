" Basics
set nocompatible
set autoindent
set number
set wildmode=longest,list " get bash-like tab completions

" Searching
set showmatch
set ignorecase
set hlsearch
set incsearch

" Tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" misc
set cc=120
set clipboard=unnamedplus " using system clipboard
set cursorline
set ttyfast " Speed up scrolling in Vim

" syntax
filetype plugin indent on
syntax on
filetype plugin on

" remap navigation keys
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

" plugins
call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'scrooloose/nerdtree'
call plug#end()
