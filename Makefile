plugin/packer_compiled.lua: init.lua
	nvim --headless -c 'autocmd User PackerCompileDone quitall' -c 'PackerCompile'
