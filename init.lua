vim.opt.guifont = 'ProFontIIx:h9'
--vim.opt.guifont = 'Fira Code:h11'
vim.opt.background = 'light'

if vim.g.neovide then
	vim.g.neovide_padding_left = 2
	vim.g.neovide_padding_right = 2
	vim.g.neovide_padding_top = 2
	vim.g.neovide_padding_bottom = 2

	vim.g.neovide_refresh_rate = 15
	vim.g.neovide_refresh_rate_idle = 1

	local guifontsize = 9
	local guifontname = 'ProFontIIx'

	function SetFontSize(size)
		guifontsize = size
		vim.opt.guifont = guifontname .. ':h' .. guifontsize
		print('Gui-font size set to: ' .. guifontsize)
	end
	function AdjustFontSize(amount)
		SetFontSize(guifontsize + amount)
	end

	-- This should use Control on everything but Darwin
	local zoom_keys = {'<C', '<D'}
	local zoom_key = zoom_keys[1 + vim.fn.has('macunix')]
	vim.keymap.set('n', zoom_key..'-+>', function() AdjustFontSize(1) end )
	vim.keymap.set('n', zoom_key..'-->', function() AdjustFontSize(-1) end )
	vim.keymap.set('n', zoom_key..'-0>', function() SetFontSize(9) end )

	vim.opt.title = true
end

vim.opt.cursorline = true

vim.opt.mouse = "nvi"

vim.opt.wildmode = "full:longest"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.linebreak = true

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
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
	{ 'NLKNguyen/papercolor-theme',
		lazy = false,
		priority = 1000,
		init = function()
			vim.g.PaperColor_Theme_Options = {
				theme = {
					default = {
						allow_bold = 0,
						allow_italic = 0,
						override = {
							-- Change the VertSplit to be a thin blue line without background
							-- Try to invert the setting in the theme...
							vertsplit_fg = {'#eeeeee', '255'},
							vertsplit_bg = {'#005f87', '24'},
						},
					},
				},
			}
		end,
		config = function()
			vim.cmd.colorscheme('PaperColor')
		end,
	},

	{ 'itchyny/lightline.vim',
		dependencies = {
			{'spywhere/lightline-lsp'},
		},
		config = function()
			-- Other "modeline" settings
			vim.opt.showmode = false  -- This is indicated by lightline
			vim.opt.showcmd = true

			vim.cmd([[
			function! LightLineProjectName()
				return fnamemodify(getcwd(), ':~:t')
			endfunction
			function! LightLineRelativePath()
				return expand('%:~:.')
			endfunction
			]])

			vim.g.lightline = {
				colorscheme = 'PaperColor',
				component_expand = {
					linter_hints = 'lightline#lsp#hints',
					linter_infos = 'lightline#lsp#infos',
					linter_warnings = 'lightline#lsp#warnings',
					linter_errors = 'lightline#lsp#errors',
					linter_ok = 'lightline#lsp#ok',
				},
				component_function = {
					projectname = 'LightLineProjectName',
					projectrelative = 'LightLineRelativePath',
				},
				component_type = {
					linter_hints = 'right',
					linter_infos = 'right',
					linter_warnings = 'warning',
					linter_errors = 'error',
					linter_ok = 'right',
				},
				active = {
					left = {
						{ 'mode', 'paste' },
						--{ 'projectname', 'readonly', 'relativepath', 'modified' },
						{ 'projectname', 'readonly', 'projectrelative', 'modified' },
					},
					right = {
						-- Default fields
						{ 'lineinfo' },
						{ 'percent' },
						{ 'filetype' },  -- 'fileformat', 'fileencoding',
						-- Lsp diagnostics
						{ 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_hints', 'linter_ok' },
					},
				},
				inactive = {
					left = {
						{ 'projectname', 'relativepath' },
					},
				},
			}
		end,
	},

	{ 'tpope/vim-fugitive',
		lazy = true,
		cmd = { "Git" },
		keys = {
			{'<leader>gs', '<cmd>Git<cr>', desc = 'Git status' },
		},
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

	-- Nvim Tree seems faster than Neotree (for now)
	-- TODO: WTF is Oil.nvim?
	-- TODO: Check CHADTree https://github.com/ms-jpq/chadtree
	{ 'nvim-tree/nvim-tree.lua',
		tag = 'v1.0',
		keys = {
			{"<F2>", "<CMD>NvimTreeToggle<CR>", desc = "NvimTree" },
		},
		cmd = {"NvimTreeOpen", "NvimTreeToggle"},
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
			vim.opt.timeout = true
			vim.opt.timeoutlen = 500
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

	{ 'lukas-reineke/indent-blankline.nvim',
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

	{ 'nvim-telescope/telescope.nvim',
		tag = '0.1.5',
		lazy = true,
		dependencies = {
			'nvim-lua/plenary.nvim',
			{'nvim-telescope/telescope-project.nvim',
				branch = 'master',
			},
			-- 'stevearc/aerial.nvim',  -- For Aerial, installation and config defined separately
		},
		config = function()
			local telescope = require('telescope')

			telescope.setup({
				defaults = {
					file_ignore_patterns = { "^venv", "^__pycache__" },
					layout_strategy = "vertical",
					layout_config = {
						height = 0.95,
						width = 0.95,
					},
				},
				extensions = {
					aerial = {
						show_nesting = {
							["_"] = true,  -- default
							-- json = false,
							-- yaml = false,
						},
					},
					project = {
						base_dirs = {
							'~/Documents/Projects',
						},
					},
				},
			})

			telescope.load_extension('project')
			telescope.load_extension('aerial')
		end,
		cmd = { 'Telescope' },
		keys = {
			{ '<leader> ', '<cmd>Telescope find_files<cr>', desc = 'Telescope find_files' },
			{ '<leader>bb', '<cmd>Telescope buffers<cr>', desc = 'Telescope buffers' },
			{ '<leader>mo', '<cmd>Telescope aerial<cr>', desc = 'Telescope Overview' },
			{ '<leader>pp', '<cmd>Telescope project<cr>' },
		},
	},

	-- LSP/Completion
	{ -- COQ Completion
		'ms-jpq/coq_nvim',
		branch = 'coq',
		lazy = true,
		cmd = {'COQnow', 'COQhelp'},
		dependencies = {
			{ 'ms-jpq/coq.artifacts', branch = 'artifacts' },
		},
	},
	{ 'neovim/nvim-lspconfig',
		--tag = 'v0.1.7',
		version = '0.1.7',
		dependencies = {
			-- Neodev has been deprecated
			-- {'folke/neodev.nvim', enabled = false, opts = {}},  -- LSP settings for neovim config and plugins
		},
		config = function()
			-- Inspirational setup
			-- https://github.com/AstroNvim/AstroNvim

			local lspconfig = require('lspconfig')
			local util = require('lspconfig/util')

			local path = util.path

			local function get_python_path(workspace)
				if vim.env.VIRTUAL_ENV then
					return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
				end

				local match = vim.fn.glob(path.join(workspace, '.venv'))
				if match ~= '' then
					return path.join(match, 'bin', 'python')
				end

				return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
			end

			lspconfig.rust_analyzer.setup({
				cmd = { vim.fn.expand('~/') .. "/.cargo/bin/rustup", "run", "stable", "rust-analyzer" },
				--on_attach = on_attach,
				settings = {
					["rust-analyzer"] = {},
				},
			})
			lspconfig.pyright.setup({
				--on_attach = on_attach,
				cmd = {"/opt/homebrew/bin/pyright-langserver", "--stdio"},
				-- https://github.com/neovim/nvim-lspconfig/issues/500
				before_init = function(_, config)
					config.settings.python.pythonPath = get_python_path(config.root_dir)
				end,
			})
			lspconfig.lua_ls.setup({})

			-- LSP Configs
			vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { silent = true, desc = 'Display diagnostics' })
			vim.keymap.set('n', '[d', function () vim.diagnostic.jump({count=-1, float=true}) end, { silent = true, desc = 'Previous diagnostic' })
			vim.keymap.set('n', ']d', function () vim.diagnostic.jump({count=1, float=true}) end, { silent = true, desc = 'Next diagnostic' })

			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('UserLspConfig', {}),
				callback = function(ev)
					local bindopts = { noremap = true, silent = true, buffer = ev.buf }

					-- Support for inlay_hint was added in 0.10
					if vim.fn.has("nvim-0.10") == 1 then
						vim.lsp.inlay_hint.enable()
					end

					-- Enable completion triggered by <C-x><C-o>
					-- vim.bo[ev.buf].omnifunc = 'v:lua.lim.lsp.omnifunc'

					--	--vim.keymap.set('n', 'gi', vim.lsp.buf.signature_help, bindopts)
					--	vim.keymap.set('n', 'go', vim.lsp.buf.hover, bindopts)
					--	vim.keymap.set('n', 'gO', vim.lsp.buf.code_action, bindopts)

					--	local builtin = require('telescope.builtin')
					--	vim.keymap.set('n', 'gl', builtin.lsp_implementations, bindopts)
					--	vim.keymap.set('n', 'gL', builtin.lsp_references, bindopts)
					--	vim.keymap.set('n', 'gd', builtin.lsp_definitions, bindopts)
					--	vim.keymap.set('n', 'gD', builtin.lsp_type_definitions, bindopts)

					-- Buffer local mappings.
					--vim.keymap.set('n', 'gi', vim.lsp.buf.signature_help, bindopts)
					vim.keymap.set('n', 'go', vim.lsp.buf.hover, bindopts)
					vim.keymap.set('n', 'gO', vim.lsp.buf.code_action, bindopts)

					local builtin = require('telescope.builtin')
					vim.keymap.set('n', 'gl', builtin.lsp_implementations, bindopts)
					vim.keymap.set('n', 'gL', builtin.lsp_references, bindopts)
					vim.keymap.set('n', 'gd', builtin.lsp_definitions, bindopts)
					vim.keymap.set('n', 'gD', builtin.lsp_type_definitions, bindopts)
				end,
			})
		end,
	},
	{  -- Replaces folke/neodev.nvim
		-- Placed in separate statement instead of dependency
		-- for lspconfig to enable lazy loading.
		'folke/lazydev.nvim',
		lazy = true,
		ft = 'lua',
		opts = {},
	},
	--{  -- Automatically display diagnostics
	--	-- This seems to be broken
	--	'dgagn/diagflow.nvim',
	--	--event = 'LspAttach',
	--	opts = {}
	--},
	{
		'nvim-treesitter/nvim-treesitter',
		version = '0.9.2',
		build = ':TSUpdate',
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = { "lua", "vim", "rust", "python", "markdown" },
			})
		end,
	},
	{ -- File structure / overview via Aerial
		'stevearc/aerial.nvim',
		version = '2.5.0',
		cmd = { 'AerialToggle' },
		keys = {
			{'<F4>', '<cmd>AerialToggle!<cr>', desc = "Aerial overview" },
		},
		opts = {
			backends = { 'lsp', 'treesitter', 'markdown' },
			layout = {
				default_direction = "prefer_right",
				placement = "edge",
			},
			show_guides = true,
			-- guides = {
			-- 	mid_item = "├ ",
			-- 	last_item = "└ ",
			-- 	nested_top = "│ ",
			-- 	whitespace = "  ",
			-- },
		},
		dependencies = { 'nvim-treesitter/nvim-treesitter' },
	},

	-- Other colorschemes
	{ 'morhetz/gruvbox',
		lazy = true,
		init = function()
			vim.g.gruvbox_bold = 0;
		end,
	},
	{ 'romgrk/doom-one.vim', lazy = true },
	{'sonph/onehalf', lazy = true,
		rtp = { paths = { 'vim' } },
	},
	{ 'tomasr/molokai', lazy = true },
	{ 'tpope/vim-vividchalk', lazy = true },
	--{ 'meain/hima-vim', lazy = true },
})

-- Misc mappings
vim.api.nvim_set_keymap('n', '<F3>', '<CMD>set number!<CR>:echo "Line numbers: " . strpart("OffOn", 3* &number, 3)<CR>',
                        { silent = true })

vim.opt.foldmethod = 'marker'

-- Highlight yanked region (:h lua-highlight)
-- Inspired by https://jdhao.github.io/2020/05/22/highlight_yank_region_nvim/
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	callback = function()
		vim.highlight.on_yank({higroup="IncSearch", timeout=150})
	end,
})

-- Folding for markdown
vim.api.nvim_create_autocmd({"FileType"}, {
	pattern = "markdown",
	callback = function()
		vim.opt_local.foldexpr="MarkdownFold()"
		vim.opt_local.foldmethod="expr"
	end,
})

-- Better fold text
-- https://essais.co/better-folding-in-neovim/
-- http://gregsexton.org/2011/03/27/improving-the-text-displayed-in-a-vim-fold.html
vim.cmd [[
function! CustomFoldText()
	let text = getline(v:foldstart) . "..."

	return text
endfunction
]]
