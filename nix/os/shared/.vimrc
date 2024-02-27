" significant portions taken from <https://www.mojotech.com/blog/vimrc-tutorial/>

" disable `vi` compatibility
set nocompatible

" backspace behavior
set backspace=indent,eol,start

" leader to space
" let mapleader = "\<Space>"

" safety
set modelines=0

" enable rich color
set t_Co=256

" SHOW TRAILING WHITESPACE WOOHOO
set list
set listchars=tab:>-,trail:.,extends:#,nbsp:.

" hide buffers instead of closing them
set hidden

" command history & undo history
set history=100
set undolevels=100

" indenting
set expandtab " change tabs to spaces--will this fuck with makefiles?
set tabstop=2
set softtabstop=2
set shiftwidth=2
set shiftround
set smarttab
set autoindent
set copyindent
set nowrap " controversial

" do not fold (hide) regions of code
set nofoldenable

" ruler at column limit
set ruler
" set colorcolumn=100 " imo better than 80

" line numbers
set nu

" syntax highlighting
syntax on
filetype on
filetype plugin on
filetype indent on

" search behavior
set incsearch " match as you type
" set ignorecase " ignore case
" set smartcase " ...except when your search is capitalized

" day/night coloring
set background=dark
" if strftime("%H") >= 5 && strftime("%H") < 18
"   set background=light
" else
"   set background=dark
" endif

" keep 2 lines above/below the cursor when scrolling
set scrolloff=8
set sidescrolloff=8

" shut the fuck up
" set visualbell " OUCH
set noerrorbells
set belloff=all

" detect non-Vim file changes & read them into the buffer
set autoread

" status bar
set laststatus=2
set showmode
set showcmd

" rendering
set ttyfast

" autocompletion
set wildmenu
set wildmode=list:longest

" update more often
" set updatetime=250