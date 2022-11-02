" add line number
set number

" set central direcotry for swap files
set directory^=$HOME/.vim/tmp//

" colors are fun
syntax on

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Vim plugin for generating images of source code using https://github.com/Aloxaf/silicon
Plugin 'segeljakt/vim-silicon'

" A tree explorer plugin for vim.
Plugin 'scrooloose/nerdtree'

" Lean & mean status/tabline for vim that's light as air.
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" super simple vim plugin to show the list of buffers in the command bar
Plugin 'bling/vim-bufferline'

" 🔣 Adds file type glyphs/icons to popular Vim plugins: NERDTree, vim-airline, Powerline, Unite, vim-startify and more
Plugin 'ryanoasis/vim-devicons'
Plugin 'ryanoasis/vim-webdevicons'

" Extra syntax and highlight for nerdtree files
Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'

" Typescript syntax files for Vim
Plugin 'leafgarland/typescript-vim'

" A Vim plugin for Prettier
Plugin 'prettier/vim-prettier'

" Nord theme
Plugin 'arcticicestudio/nord-vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required

" nice colorschema
colorscheme nord

filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" NERD tree config
" How can I open NERDTree automatically when vim starts up on opening a directory?
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

" How can I close vim if the only window left open is a NERDTree?
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let g:NERDTreeNodeDelimiter = "\u00a0"
let NERDTreeShowHidden = 1
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.maxlinenr = '㏑'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.whitespace = 'Ξ'

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = ''
