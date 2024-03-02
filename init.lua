vim.opt.guifont = 'ProFontWindows:h9'
--vim.opt.guifont = 'Fira Code:h11'
vim.opt.background = 'light'

vim.opt.cursorline = true

vim.opt.mouse = "nvi"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.g.mapleader = ' '

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ 'NLKNguyen/papercolor-theme',
		lazy = false,
		init = function()
			vim.g.PaperColor_Theme_Options = {
				theme = {
					default = {
						allow_bold = 0,
						allow_italic = 0,
						-- TODO: Fixa att VertSplit ser inverterad ut
						--light = {
						--	-- Change the VertSplit to be a thin blue line without background
						--	vertsplit_fg = {}
						--},
					},
				},
			}
		end,
		config = function()
			vim.cmd('colorscheme PaperColor')
		end,
	},

	{ 'itchyny/lightline.vim',
		config = function()
			-- Other "modeline" settings
			vim.opt.showmode = false  -- This is indicated by lightline
			vim.opt.showcmd = true

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
		end,
	},

	{ 'tpope/vim-surround' },
	{ 'tpope/vim-commentary',
		--config = function()
		--	vim.api.nvim_create_autocmd('FileType', {
		--		pattern = 'rust',
		--		callback = function(args)
		--			--vim.bo[args.buf].commentstring = '// %s'
		--		end,
		--	})
		--end,
	},
	{ 'tpope/vim-fugitive' },

	-- Nvim Tree seems faster than Neotree (for now)
	-- TODO: WTF is Oil.nvim?
	{ 'nvim-tree/nvim-tree.lua',
		tag = 'v1.0',
		keys = {
			{"<F2>", "<CMD>NvimTreeToggle<CR>", desc = "NvimTree" },
		},
		cmd = "NvimTreeToggle",
		opts = {
			git = {
				enable = false,
			},
			renderer = {
				add_trailing = true,
				highlight_git = false,
				indent_markers = {
					enable = true,
					icons = {
						edge = "│",
						item = "├",
						corner = "└",
						none = " ",
					},
				},
				icons = {
					show = {
						file = false,
						folder = false,
						folder_arrow = false,
					},
					--glyphs = {
					--	folder = {
					--		arrow_closed = ">",
					--		arrow_open = "v",
					--	},
					--},
					webdev_colors = false,
				},
			},
		},
	},

	{ 'folke/which-key.nvim',
		init = function()
			vim.o.timeout = true
			vim.o.timoutlen = 500
		end,
		config = function()
			local wk = require("which-key")

			wk.setup()
			-- TODO: Describe bindings instead
			-- wk.register({
			-- 	g = {
			-- 		o = 'Hover',
			-- 		O = 'Code Actions',
			-- 		l = 'Go to Implementations',
			-- 		L = 'Go to References',
			-- 		d = 'Go to Definitions',
			-- 		D = 'Go to Type Definitions',
			-- 	}
			-- })
		end,
	},

	{
		'lukas-reineke/indent-blankline.nvim',
		main = 'ibl',
		keys = {
			{ '<leader>ig', '<cmd>IBLToggle<cr>', desc = "IndentGuides" },
		},
		cmd = "IBLToggle",
		opts = {
			scope = {
				enabled = true,
				show_start = true,
			},
		},
	},
})

--require('packer').startup(
local foo = (function(use)

	-- Telescope
	use({
		{
			'nvim-telescope/telescope.nvim',
			requires = { 'nvim-lua/plenary.nvim' },
			config = function()
				require('telescope').setup({
					defaults = {
						layout_strategy = "vertical",
						layout_config = {
							height = 0.95,
							width = 0.95,
						},
					},
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
		},
		{
			'nvim-telescope/telescope-project.nvim',
			after = 'telescope.nvim',
			requires = { 'nvim-telescope/telescope.nvim' },
			config = function()
				require('telescope').load_extension('project')
				vim.api.nvim_set_keymap('n', '<leader>pp', '<cmd>Telescope project<cr>', { silent = true })
			end,
		},
	})

	-- Neogit
	use {
		'TimUntersberger/neogit',
		commit = '7b7b7bb',
		requires = 'nvim-lua/plenary.nvim',
		config = function()
			require('neogit').setup({
				disable_commit_confirmation = true,
				use_magit_keybindings = true,
			})
			vim.api.nvim_set_keymap('n', '<leader>gs', '<cmd>Neogit<cr>', { silent = true })
		end
	}

	-- Tagbar ( Replaced by Aerial.vim
	--use {
	--	'preservim/tagbar',
	--	config = function()
	--		vim.api.nvim_set_keymap('n', '<F4>', '<cmd>TagbarToggle<cr>', { silent = true })
	--	end,
	--}

	use {
		'nvim-treesitter/nvim-treesitter',
		run = function () require('nvim-treesitter.install').update({ with_sync = true }) end,
	}

	-- Colorschemes
	use {
		'sonph/onehalf',
		rtp = 'vim',
		--config = function() vim.cmd('colorscheme onehalflight') end,
	}
	use 'morhetz/gruvbox'
	use 'romgrk/doom-one.vim'
	use 'tomasr/molokai'


	-- TODO: Get proper rust support working
	-- Guide to get lsp working
	-- https://rsdlt.github.io/posts/rust-nvim-ide-guide-walkthrough-development-debug/
	--
	-- Inspirational setup
	-- https://github.com/AstroNvim/AstroNvim

	-- LSP Configs
	vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { silent = true })
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { silent = true })
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { silent = true })

	-- TODO: Fix on_attach so keybindings and Aerial works properly
	-- I do not understand why this does not work. It seems that the 'hello
	-- from the outside below is not displayed if it is in the config function
	-- of lspconfig.
	-- Is it a scope issue? the function is compile earlier than the execution
	-- so the symbol isn't available?
	-- This issue seems related:
	-- https://github.com/neovim/nvim-lspconfig/issues/2155
	use {
		'neovim/nvim-lspconfig',
		config = function ()
			local on_attach = function (client, bufnr)
				local bindopts = { noremap=true, silent=true, buffer=bufnr }


				vim.keymap.set('n', 'go', vim.lsp.buf.hover, bindopts)
				vim.keymap.set('n', 'gO', vim.lsp.buf.code_action, bindopts)

				local builtin = require('telescope.builtin')
				vim.keymap.set('n', 'gl', builtin.lsp_implementations, bindopts)
				vim.keymap.set('n', 'gL', builtin.lsp_references, bindopts)
				vim.keymap.set('n', 'gd', builtin.lsp_definitions, bindopts)
				vim.keymap.set('n', 'gD', builtin.lsp_type_definitions, bindopts)
			end
			require('lspconfig')['pyright'].setup({
				on_attach = on_attach,
				cmd = {"/home/emil/Documents/Projects/python-json-scheme-viewer/venv/bin/pyright-langserver", "--stdio"},
			})
			require('lspconfig')['rust_analyzer'].setup({
				cmd = {"/Users/emieri/.cargo/bin/rustup", "run", "stable", "rust-analyzer"},
				on_attach = on_attach,
				settings = {
				 	["rust-analyzer"] = {},
				},
			})
		end,
	}

	-- Completion via Cmp
	use {
		'hrsh7th/nvim-cmp',
		requires = {
			'hrsh7th/cmp-nvim-lsp',
			{'hrsh7th/cmp-nvim-lsp-signature-help', after = 'nvim-cmp' },
		},
		config = function ()
			local cmp = require('cmp')

			local fallback_or = function (not_fallback)
				local executor = function (fallback)
					if cmp.visible() then
						not_fallback()
					else
						fallback()
					end
				end
				return executor
			end

			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					['<Tab>'] = cmp.mapping.confirm({ select = true }),
					['<C-n>'] = fallback_or(cmp.select_next_item),
					['<C-p>'] = fallback_or(cmp.select_prev_item),
				}),
				window = {
					--completion = cmp.config.window.bordered(),
					--documentation = cmp.config.window.bordered(),
				},
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'nvim_lsp_signature_help' },
				}),
			})
		end,
	}

	-- File structure / overview via Aerial
	use {
		'stevearc/aerial.nvim',
		commit = '888b672',
		config = function ()
			local aerial = require('aerial')
			aerial.setup({
				backends = { "lsp", "treesitter", "markdown" },
				layout = {
					default_direction = "prefer_right",
					placement = "edge",
				},
				attach_mode = "window",
				show_guides = true,
				guides = {
					mid_item = "├ ",
					last_item = "└ ",
					nested_top = "│ ",
					whitespace = "  ",
				},
			})

			-- This might have to be moved to existing on_attach in case such exists
			--require('lspconfig').vimls.setup()  -- { on_attach = aerial.on_attach })

			vim.api.nvim_set_keymap('n', '<F4>', '<cmd>AerialToggle!<cr>', { silent = true })
			vim.api.nvim_set_keymap('n', '<leader>mo', '<cmd>Telescope aerial<cr>', { silent = true })

			require('telescope').load_extension('aerial')
		end,
	}

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require('packer').sync()
	end
end)

-- Misc mappings
vim.api.nvim_set_keymap('n', '<F3>', '<CMD>set number!<CR>:echo "Line numbers: " . strpart("OffOn", 3* &number, 3)<CR>',
                        { silent = true })

vim.opt.foldmethod = 'marker'

-- Highlight yanked region (:h lua-highlight)
-- Inspired by https://jdhao.github.io/2020/05/22/highlight_yank_region_nvim/
vim.cmd [[
au TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=150}
]]

-- Folding for markdown
vim.cmd [[
autocmd FileType markdown setlocal foldexpr=MarkdownFold()
autocmd FileType markdown setlocal foldmethod=expr
]]

-- Better fold text
-- https://essais.co/better-folding-in-neovim/
-- http://gregsexton.org/2011/03/27/improving-the-text-displayed-in-a-vim-fold.html
vim.cmd [[
function! CustomFoldText()
	let text = getline(v:foldstart) . "..."

	return text
endfunction
]]
