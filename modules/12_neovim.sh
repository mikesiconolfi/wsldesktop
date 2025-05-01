#!/bin/bash

# NeoVim installation and configuration module

install_neovim() {
    section "Setting up NeoVim"
    
    # Check if NeoVim is already installed
    if command -v nvim &> /dev/null; then
        info "NeoVim is already installed. Checking version..."
        nvim --version | head -n 1
    else
        info "Installing NeoVim..."
        
        # Add the PPA for the latest stable version
        sudo add-apt-repository -y ppa:neovim-ppa/stable >> "$LOG_FILE" 2>&1 || {
            error "Failed to add NeoVim PPA"
            return 1
        }
        
        # Update package lists
        sudo apt-get update >> "$LOG_FILE" 2>&1 || {
            error "Failed to update package lists"
            return 1
        }
        
        # Install NeoVim
        sudo apt-get install -y neovim >> "$LOG_FILE" 2>&1 || {
            error "Failed to install NeoVim"
            return 1
        }
        
        info "NeoVim installed successfully"
    fi
    
    # Install dependencies for plugins
    info "Installing dependencies for NeoVim plugins..."
    sudo apt-get install -y python3-pip nodejs npm ripgrep fd-find >> "$LOG_FILE" 2>&1 || {
        error "Some dependencies could not be installed. Some plugins may not work correctly."
    }
    
    # Install Python provider for NeoVim
    info "Installing Python provider for NeoVim..."
    pip3 install --user pynvim >> "$LOG_FILE" 2>&1 || {
        error "Failed to install Python provider for NeoVim"
    }
    
    # Create NeoVim config directory if it doesn't exist
    mkdir -p ~/.config/nvim
    
    # Create init.vim configuration file
    info "Creating NeoVim configuration..."
    cat > ~/.config/nvim/init.vim << 'EOF'
" NeoVim Configuration

" General Settings
set number                      " Show line numbers
set relativenumber              " Show relative line numbers
set expandtab                   " Use spaces instead of tabs
set tabstop=4                   " Number of spaces tabs count for
set shiftwidth=4                " Size of an indent
set softtabstop=4               " Number of spaces in tab when editing
set smartindent                 " Insert indents automatically
set hidden                      " Allow buffer switching without saving
set ignorecase                  " Case insensitive searching
set smartcase                   " Case-sensitive if expression contains a capital letter
set nobackup                    " No backup files
set nowritebackup               " No backup files during editing
set noswapfile                  " No swap files
set undofile                    " Persistent undo
set undodir=~/.config/nvim/undodir  " Undo directory
set incsearch                   " Shows the match while typing
set hlsearch                    " Highlight search results
set scrolloff=8                 " Start scrolling when 8 lines from top or bottom
set signcolumn=yes              " Always show sign column
set colorcolumn=80              " Show column at 80 characters
set termguicolors               " Enable true colors support
set updatetime=300              " Faster completion
set timeoutlen=500              " Faster key sequence completion
set clipboard=unnamedplus       " Use system clipboard
set mouse=a                     " Enable mouse support
set cursorline                  " Highlight current line
set showmatch                   " Show matching brackets
set wildmenu                    " Command-line completion
set wildmode=longest:full,full  " Command-line completion mode
set completeopt=menuone,noselect " Completion options
set splitright                  " Vertical splits to the right
set splitbelow                  " Horizontal splits below

" Create undodir if it doesn't exist
if !isdirectory($HOME."/.config/nvim/undodir")
    call mkdir($HOME."/.config/nvim/undodir", "p", 0700)
endif

" Install vim-plug if not found
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" Plugins
call plug#begin('~/.config/nvim/plugged')

" Theme
Plug 'morhetz/gruvbox'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" File explorer
Plug 'preservim/nerdtree'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Auto pairs for brackets, quotes, etc.
Plug 'jiangmiao/auto-pairs'

" Comment stuff out
Plug 'tpope/vim-commentary'

" Syntax highlighting
Plug 'sheerun/vim-polyglot'

" AWS specific plugins
Plug 'hashivim/vim-terraform'
Plug 'juliosueiras/vim-terraform-completion'
Plug 'matt-bartel/vim-cloudformation'

" Code completion and LSP support
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" Theme settings
colorscheme gruvbox
set background=dark

" Key mappings
let mapleader = " "  " Set leader key to space

" NERDTree settings
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>

" FZF settings
nnoremap <leader>p :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>

" Buffer navigation
nnoremap <leader>h :bprevious<CR>
nnoremap <leader>l :bnext<CR>
nnoremap <leader>q :bdelete<CR>

" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Terminal mode
tnoremap <Esc> <C-\><C-n>
nnoremap <leader>t :terminal<CR>

" AWS specific settings
autocmd FileType terraform setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType json setlocal tabstop=2 shiftwidth=2 softtabstop=2

" CoC extensions
let g:coc_global_extensions = [
  \ 'coc-json',
  \ 'coc-yaml',
  \ 'coc-tsserver',
  \ 'coc-python',
  \ 'coc-sh',
  \ 'coc-docker',
  \ ]

" CoC settings
" Use tab for trigger completion with characters ahead and navigate
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" AWS specific key mappings
autocmd FileType terraform nnoremap <leader>ti :!terraform init<CR>
autocmd FileType terraform nnoremap <leader>tp :!terraform plan<CR>
autocmd FileType terraform nnoremap <leader>ta :!terraform apply<CR>

" CloudFormation template validation
autocmd FileType yaml,json nnoremap <leader>cv :!aws cloudformation validate-template --template-body file://%<CR>
EOF

    # Create CoC configuration
    info "Creating CoC configuration..."
    mkdir -p ~/.config/nvim/
    cat > ~/.config/nvim/coc-settings.json << 'EOF'
{
  "suggest.noselect": false,
  "suggest.enablePreselect": false,
  "suggest.triggerAfterInsertEnter": true,
  "suggest.timeout": 5000,
  "suggest.enablePreview": true,
  "suggest.floatEnable": true,
  "suggest.detailField": "preview",
  "suggest.snippetIndicator": "►",
  "diagnostic.errorSign": "✖",
  "diagnostic.warningSign": "⚠",
  "diagnostic.infoSign": "ℹ",
  "diagnostic.hintSign": "➤",
  "diagnostic.virtualText": true,
  "diagnostic.virtualTextPrefix": " ❯❯❯ ",
  "codeLens.enable": true,
  "list.indicator": "❯",
  "list.selectedSignText": "●",
  "coc.preferences.formatOnSaveFiletypes": [
    "javascript",
    "typescript",
    "typescriptreact",
    "json",
    "javascriptreact",
    "typescript.tsx",
    "python",
    "terraform",
    "yaml",
    "markdown",
    "html",
    "css"
  ],
  "yaml.schemas": {
    "https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json": ["/*cloudformation*", "*.cf.yaml", "*.cf.yml"]
  },
  "languageserver": {
    "terraform": {
      "command": "terraform-ls",
      "args": ["serve"],
      "filetypes": ["terraform", "tf"],
      "initializationOptions": {},
      "settings": {}
    }
  }
}
EOF

    # Add aliases to ZSH configuration
    info "Adding NeoVim aliases to ZSH configuration..."
    if [ -f ~/.zshrc ]; then
        if ! grep -q "# NeoVim aliases" ~/.zshrc; then
            cat >> ~/.zshrc << 'EOF'

# NeoVim aliases
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias vimdiff="nvim -d"
EOF
        else
            info "NeoVim aliases already exist in .zshrc"
        fi
    else
        error "Could not find .zshrc to add NeoVim aliases"
    fi
    
    # Install plugins
    info "Installing NeoVim plugins (this may take a moment)..."
    nvim --headless +PlugInstall +qall >> "$LOG_FILE" 2>&1 || {
        error "Failed to install NeoVim plugins automatically"
        info "You can install plugins manually by opening NeoVim and running :PlugInstall"
    }
    
    # Install CoC extensions
    info "Installing CoC extensions..."
    mkdir -p ~/.config/coc/extensions
    cd ~/.config/coc/extensions
    if [ ! -f package.json ]; then
        echo '{"dependencies":{}}' > package.json
    fi
    npm install --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod \
        coc-json coc-yaml coc-tsserver coc-python coc-sh coc-docker >> "$LOG_FILE" 2>&1 || {
        error "Failed to install some CoC extensions"
        info "You can install extensions manually by opening NeoVim and running :CocInstall <extension-name>"
    }
    
    # Install Terraform language server if Terraform module is installed
    if command -v terraform &> /dev/null; then
        info "Installing Terraform language server..."
        # Use the official HashiCorp install script with the correct URL
        curl -fsSL https://releases.hashicorp.com/terraform-ls/0.31.4/terraform-ls_0.31.4_linux_amd64.zip -o terraform-ls.zip >> "$LOG_FILE" 2>&1 && \
        unzip terraform-ls.zip >> "$LOG_FILE" 2>&1 && \
        chmod +x terraform-ls && \
        sudo mv terraform-ls /usr/local/bin/ >> "$LOG_FILE" 2>&1 || {
            error "Failed to install Terraform language server"
            info "You can install it manually from https://github.com/hashicorp/terraform-ls/releases"
        }
        rm -f terraform-ls.zip 2>/dev/null
    fi
    
    info "NeoVim setup complete!"
    info "You can start NeoVim by typing 'nvim' or using the aliases: vim, vi, or v"
    info "The first time you open NeoVim, it may install additional plugins"
    
    # Ask to set ZSH as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        if confirm "Would you like to set ZSH as your default shell?"; then
            echo "User chose to set ZSH as default shell" >> "$LOG_FILE"
            chsh -s $(which zsh) || {
                error "Failed to set ZSH as default shell"
                info "You can manually set ZSH as your default shell with: chsh -s $(which zsh)"
            }
            info "ZSH has been set as your default shell. Changes will take effect on next login."
        else
            echo "User chose not to set ZSH as default shell" >> "$LOG_FILE"
        fi
    fi
}
