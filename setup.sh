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

function setup_stm32_cmsis() {
    echo "> Setting up CMSIS libraries for STM32F303x MCU"

    echo "> Creating directories in $HOME/devel/stm32/cmsis..."
    STMDevelDir="$HOME/devel/stm32/cmsis"
    CMSISDir="$STMDevelDir/CMSIS"
    DeviceDir="$CMSISDir/Device"

    mkdir -p $STMDevelDir
    mkdir -p $CMSISDir
    mkdir -p $DeviceDir
    echo "> Created directories in $HOME/devel/stm32/cmsis"

    echo "> Cloning CMSIS_5 and cmsis_device_f3 directories..."
    git clone https://github.com/ARM-software/CMSIS_5 $CMSISDir
    cd $DeviceDir
    mkdir ST && cd ST
    clone https://github.com/STMicroelectronics/cmsis_device_f3 STM32F3
    echo "> Cloned CMSIS_5 and cmsis_device_f3 directories"

    echo "> Removing unnecessary directories and files"
    for $dir in $CMSISDir; do
	if [[ $dir == "Core" ]] ; then
	    continue
	else
	    rm -rf $dir
	fi
    done

    for $dir in $DeviceDir; do
	if [[ $dir == "STM32F3" ]] ; then
	    continue
	else
	    rm -rf $dir
	fi
    done
    echo "> Removed unnecessary directories and files"

    echo "> STM32 CMSIS set up"
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
	;;
    "setup-vim")
	setup_vim
	;;
    "setup-alacritty")
	setup_alacritty
	;;
    "setup-emacs")
	setup_emacs
	;;
    "setup-stm32-cmsis")
	setup_stm32_cmsis
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
