#!/bin/bash

function setup_vim() {
    echo "> Setting up vim..."
    
    echo "> Copying vimrc file to $HOME..."
    cp -v ./vimrc $HOME/.vimrc
    echo "> Copied vimrc file to $HOME"

    echo "> Setting up vundle..."
    mkdir -p $HOME/.vim/bundle
    git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
    echo "> Vundle set up"

    echo "> Installing plugins..."
    vim +PluginInstall +qall
    echo "> Plugins installed"

    echo "> Vim set up"
}

function setup_neovim() {
    echo "> Setting up neovim"

    echo "> Copying init.vim to $HOME/.config/nvim..."
    mkdir -p $HOME/.config/nvim/
    cp -v init.vim $HOME/config/nvim/
    echo "> Copied init.vim to $HOME/.config/nvim"

    echo "> Setting up plug"
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    echo "> Plug set up"

    echo "> Installing plugins"
    nvim +PlugInstall +qall
    echo "> Plugins installed"

    echo "> neovim set up"
}

function setup_alacritty() {
    echo "> Setting up alacritty..."

    echo "> Copying alacritty.yml file to $HOME/.config/alacritty..."
    mkdir -p $HOME/.config/alacritty/
    cp -v ./alacritty.yml $HOME/config/alacritty/
    echo "> Copied alacritty.yml file to $HOME/.config/alacritty"

    echo "> Downloading and setting up IntelOneMono-Regular font..."
    wget https://github.com/intel/intel-one-mono/releases/download/V1.3.0/otf.zip
    unzip otf.zip
    mv otf/IntelOneMono-Regular.otf /usr/local/share/fonts
    fc-cache -f -v
    rm -rf otf.zip otf
    echo "> Downloaded and set up IntelOneMono-Regular font"

    echo "> Set up Alacritty"
}

function setup_emacs() {
    echo "> Setting up emacs..."

    echo "> Copying init.el file to $HOME/.config/emacs..."
    mkdir -p $HOME/.config/emacs
    cp -v ./init.el $HOME/.config/emacs
    echo "> Copied init.el file to $HOME/.config/emacs"

    echo "> Set up emacs"
}

function nuke_everything() {
    echo "> Nuking everything..."

    rm -rf $HOME/.configs/emacs $HOME/.configs/alacritty $HOME/.vim $HOME/.vimrc
    rm -rf /usr/local/share/fonts/IntelOneMono-Regular && fc-cache -f -v

    echo "> Nuked everything"
}

if [[ $# -ne 1 ]] ; then
    echo "Incorrect usage. Correct usage: ./setup.sh <target>"
    exit 1
fi

case $1 in
    "all")
    setup_vim
    setup_alacritty
    setup_emacs
    setup_neovim
    ;;
    "setup-vim")
    setup_vim
    ;;
    "setup-neovim")
    setup_neovim
    :;
    "setup-alacritty")
    setup_alacritty
    ;;
    "setup-emacs")
    setup_emacs
    ;;
    "nuke-everything")
    nuke_everything
    ;;
    *)
    echo "Incorrect argument. Exiting."
    exit 1
    ;;
esac

exit 0
