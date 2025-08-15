" ===========================
" Vim minimal e produtivo
" ===========================

" --- Básico e UX ---
set number                " números de linha
set relativenumber        " números relativos (melhora navegação)
set cursorline            " destaca linha atual
set showcmd               " mostra comando parcial
set showmatch             " destaca pares de (), {}, []
set nowrap                " não quebra linha automaticamente

" --- Mouse & Clipboard ---
set mouse=a               " habilita mouse (seleção/resize splits)
set clipboard=unnamedplus " integra com clipboard do SO (xclip/xsel pode ajudar)

" --- Busca inteligente ---
set ignorecase            " ignora maiúsc/minúsc na busca
set smartcase             " mas respeita maiúscula se usada
set incsearch             " mostra resultados enquanto digita
set hlsearch              " destaca resultados

" --- Indentação & Tabs ---
set expandtab             " usa espaços em vez de tabs
set tabstop=2             " largura de tab = 2
set shiftwidth=2          " shift/recuo = 2
set smartindent           " indentação automática

" --- Desempenho/qualidade de vida ---
set wildmenu              " autocomplete no :comando
set wildmode=longest:full,full
set updatetime=300
set hidden                " permite trocar de buffer sem salvar
set scrolloff=4           " margem vertical ao rolar
set sidescrolloff=8

" --- Persistência & diretórios ---
set undofile              " histórico de desfazer persistente
set undodir=~/.vim/undo//
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
silent! call mkdir($HOME."/.vim/undo", "p", 0700)
silent! call mkdir($HOME."/.vim/backup", "p", 0700)
silent! call mkdir($HOME."/.vim/swap", "p", 0700)

" --- Aparência ---
syntax on
if has('termguicolors')
  set termguicolors
endif
" Tenta usar gruvbox se existir; senão, usa default
silent! colorscheme gruvbox

" --- Netrw (explorador nativo) mais amigável ---
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_liststyle=3
let g:netrw_winsize=25

" --- Dobras (fold) ---
set nofoldenable
set foldmethod=indent
set foldlevelstart=99

" --- Statusline ---
set laststatus=2

" --- Teclas (Leader = espaço) ---
let mapleader=" "

" salvar/fechar rápido
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>

" limpar destaque da busca
nnoremap <leader><space> :nohlsearch<CR>

" alternar mostrar espaços invisíveis
set listchars=tab:»·,trail:·,extends:>,precedes:<
nnoremap <leader>tw :set list!<CR>

" splits e navegação
nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>sh :split<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" netrw (explorador) atalho
nnoremap <leader>e :Ex<CR>

" mover linhas rapidamente
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" ========== Plugins via vim-plug ==========
call plug#begin('~/.vim/plugged')

" Tema
Plug 'morhetz/gruvbox'

" Fuzzy finder (usa fzf; já instalamos antes, mas se precisar:)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Comentários (gc)
Plug 'tpope/vim-commentary'

" Surround (cs, ds, ys)
Plug 'tpope/vim-surround'

" Indicadores de diff no gutter
Plug 'airblade/vim-gitgutter'

" Syntax packs otimizados
Plug 'sheerun/vim-polyglot'

call plug#end()

" Config rápida do gruvbox
set background=dark
silent! colorscheme gruvbox

" Atalhos fzf: arquivos, buffers, lines, grep
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fl :Lines<CR>
nnoremap <leader>fg :GFiles?<CR>
nnoremap <leader>rg :Rg<CR>
