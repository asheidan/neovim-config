vim.opt.guifont = 'ProFontWindows:h9'
--vim.opt.guifont = 'Fira Code:h11'
vim.opt.background = 'light'

vim.opt.cursorline = true

vim.opt.mouse = "nvi"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.g.mapleader = ' '

local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Only required if you have packer configured as `opt`
vim.cmd('packadd packer.nvim')

require('packer').startup(function(use)

	-- Packer
	use({
		'wbthomason/packer.nvim',
		config = function() require 'plugins' end,
		cmd = {
			'PackerClean',
			'PackerCompile',
			'PackerInstall',
			'PackerProfile',
			'PackerStatus',
			'PackerSync',
			'PackerUpdate',
		},
	})

	-- Telescope
	use({
		'nvim-telescope/telescope.nvim',
		requires = { 'nvim-lua/plenary.nvim' },
		config = function()
			require('telescope').setup({
				extensions = {
					project = {
						base_dirs = {
							'~/Documents/Projects',
						},
					},
				},
			})
			vim.api.nvim_set_keymap('n', '<leader> ', '<cmd>Telescope find_files<cr>', { silent = true })
			vim.api.nvim_set_keymap('n', '<leader>bb', '<cmd>Telescope buffers<cr>', { silent = true })
		end,
	})
	use({
		'nvim-telescope/telescope-project.nvim',
		after = 'telescope.nvim',
		requires = { 'nvim-telescope/telescope.nvim' },
		config = function()
			require('telescope').load_extension('project')
			vim.api.nvim_set_keymap('n', '<leader>pp', '<cmd>Telescope project<cr>', { silent = true })
		end,
	})

	-- Vim Surround
	use 'tpope/vim-surround'

	-- Neogit
	use {
		'TimUntersberger/neogit',
		requires = 'nvim-lua/plenary.nvim',
		config = function()
			require('neogit').setup({
				disable_commit_confirmation = true,
				use_magit_keybindings = true,
			})
			vim.api.nvim_set_keymap('n', '<leader>gs', '<cmd>Neogit<cr>', { silent = true })
		end
	}

	-- Tagbar
	use {
		'preservim/tagbar',
		config = function()
			vim.api.nvim_set_keymap('n', '<F4>', '<cmd>TagbarToggle<cr>', { silent = true })
		end,
	}

	-- Lightline
	use {
		'itchyny/lightline.vim',
		config = function()
			-- Other "modeline" settings
			vim.opt.showmode = false  -- This is indicated by lightline
			vim.opt.showcmd = true
		end,
	}
	vim.cmd([[
	function! LightLineProjectName()
		return fnamemodify(getcwd(), ':~:t')
	endfunction
	]])
	vim.g.lightline = {
		colorscheme = 'PaperColor',
		component_function = {
			projectname = 'LightLineProjectName',
		},
		active = {
			left = {
				{ 'mode', 'paste' },
				{ 'projectname', 'readonly', 'relativepath', 'modified' },
			},
		},
	}

	-- Colorschemes
	use {
		'sonph/onehalf',
		rtp = 'vim',
		--config = function() vim.cmd('colorscheme onehalflight') end,
	}
	use {
		'NLKNguyen/papercolor-theme',
		config = function() vim.cmd('colorscheme PaperColor') end,
	}
	use 'morhetz/gruvbox'
	use 'romgrk/doom-one.vim'
	use 'tomasr/molokai'

	-- WhichKey
	use {
		'folke/which-key.nvim',
		config = function() require("which-key").setup() end,
	}

	-- IndentGuides
	use {
		'lukas-reineke/indent-blankline.nvim',
		config = function()
			require('indent_blankline').setup({
				show_current_context = true,
				show_current_contect_start = true,
				--show_end_of_line = true,
			})
			vim.api.nvim_set_keymap('n', '<leader>ig', '<cmd>IndentBlanklineToggle<cr>', { silent = true })
		end,
	}

	-- NvimTree
	vim.g.nvim_tree_git_hl = 0
	vim.g.nvim_tree_add_trailing = 1
	vim.g.nvim_tree_show_icons = {
		git = 0,
		folders = 0,
		files = 0,
		folder_arrows = 1,
	}
	use {
		'kyazdani42/nvim-tree.lua',
		config = function ()
			require('nvim-tree').setup({
				git = {
					enable = false,
				},
				renderer = {
					indent_markers = {
						enable = true,
						icons = {
							edge = "├ ",
							corner = "└ ",
							none = "  ",
						},
					},
					icons = {
						webdev_colors = false,
					},
				},
			})
			vim.api.nvim_set_keymap('n', '<F2>', '<cmd>NvimTreeToggle<cr>', { silent = true })
		end,
	}
	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require('packer').sync()
	end
end)

-- Misc mappings
vim.api.nvim_set_keymap('n', '<F3>', '<cmd>lua vim.opt.number = true ~= vim.opt.number<cr>',
                        { silent = true })

vim.opt.foldmethod = 'marker'

-- Highlight yanked region (:h lua-highlight)
-- Inspired by https://jdhao.github.io/2020/05/22/highlight_yank_region_nvim/
vim.cmd [[au TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=150}]]
