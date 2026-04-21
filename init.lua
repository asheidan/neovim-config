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
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
	{ 'folke/noice.nvim',
		-- TODO: Fix showcmd
		event = 'VeryLazy',
		opts = {
			cmdline = {
				format = {
					cmdline = { icon = ":" },
					search_down = { icon = "/" },
					search_up = { icon = "?" },
					-- TODO: What is filter?
					filter = { icon = "$" },
					lua = { icon = ">" },
					help = { icon = "H" },
				},
			},
			format = {  -- Format for notifications
				level = {
					-- Disabling icons because they look strange, at least in the terminal
					error = "",
					warn = "",
					info = "",
				},
			},
			presets = {
				bottom_search = true,
				-- command_palette = true,  -- I don't like the command moved to the top of the window
			},
		},
		-- TODO: Fix highlights to be less jarring
		-- Probably needs NoiceCmdlineIcon, NoiceCmdlinePopupBorder
		-- to be connected to something else than DiagnosticSignInfo.
		-- But can't do it in config without also manually calling setup.
		-- config = function()
		-- 	vim.cmd [[
		-- 		highlight link NoiceCmdlineIcon NoiceCmdline
		-- 		highlight link NoiceCmdlinePopupBorder NoiceCmdline
		-- 	]]
		-- end,
		dependencies = {
			'MunifTanjim/nui.nvim',
			'rcarriga/nvim-notify',
		},
	},

	{ 'NLKNguyen/papercolor-theme',
		lazy = false,
		priority = 1000,
		-- init = function() end,
		config = function()
			vim.g.PaperColor_Theme_Options = {
				language = {
					c = { highlight_builtins = 1 },
					cpp = { highlight_standard_library = 1 },
				},
				theme = {
					default = {
						allow_bold = 0,
						allow_italic = 0,
					},
				},
			}
			vim.cmd.colorscheme('PaperColor')
			-- Workaround for ugly separator between splits
			vim.cmd('highlight WinSeparator guifg=#005f87 guibg=#eeeeee')
		end,
	},

	{ 'nvim-lualine/lualine.nvim',
		enabled = true,
		opts = {
			options = {
				icons_enabled = false,
			},
			extensions = {
				'aerial',
				'fugitive',
				'nvim-dap-ui',
				'nvim-tree',
				'oil',
				'quickfix',
			},
			sections = {
				lualine_b = {
					{'vim.fn.fnamemodify(vim.fn.getcwd(),":~:t")', separator = '/'},  -- project-dir
					--'vim.fn.expand("%:~:.")',  -- relative path
					{ 'filename', path = 1,
						symbols = {
							modified = '+',
							readonly = '-',
						},
					},  -- relative path
				},
				lualine_c = { },  --'branch', },

				lualine_x = {
					 -- showcmd dosn't work or does something else
					'selectioncount',
					{ 'diagnostics',
						-- TODO: Change the colors to be colored backgrounds
					},
					{ 'lsp_status', show_name = false, separator = '' },
					{'filetype', separator = '' },
					{'fileformat', fmt = function(str) return (str ~= "unix") and str or "" end, separator = '' },
					{'encodint', fmt = function(str) return (str ~= "utf-8") and str or "" end },
				},
			},
			inactive_sections = {
				lualine_c = {
					{ 'filename', path = 1,
						symbols = {
							modified = '+',
							readonly = '-',
						},
					},  -- relative path
				},
			},
		},
	},

	-- Feature-adding plugins

	{ 'NeogitOrg/neogit',  -- Git-based on magit
		cmd = { 'Neogit' },
		dependencies = {
			'sindrets/diffview.nvim',  -- optional diff integration
		},
	},

	{ 'nicolasgb/jj.nvim',  -- Support for JJ (Jujutsu)
		enabled = true, -- This is _very_ new so I'll keep an eye on it
		cmd = { 'J' },
		config = function() require("jj").setup({}) end,
	},

	{
		'will133/vim-dirdiff',  -- Diff for directories
		cmd = { 'DirDiff' },
	},

	{ 'tpope/vim-fugitive',
		lazy = true,
		cmd = { "Git" },
		keys = {
			{'<leader>gs', '<cmd>Git<cr>', desc = 'Git status' },
		},
	},
	{ 'idanarye/vim-merginal',  -- Branch handling based on fugitive
		cmd = 'Merginal',
		dependencies = { 'tpope/vim-fugitive' },
		keys = {
			{'<leader>gb', '<cmd>Merginal<cr>', desc = 'Git branches (Merginal)' },
		},
	},
	{ 'lewis6991/gitsigns.nvim',
		tag = "v2.1.0",
		cmd = { 'Gitsigns' },
		keys = {
			{'<leader>ts', function() require('gitsigns').toggle_signs(true) end, desc = "Toggle Git signs"},
		},
		opts = {
			current_line_blame = false,

			on_attach = function(bufnr)
				local gitsigns = require('gitsigns')

				local function map_key(mode, keys, operation, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, keys, operation, opts)
				end

				map_key('n', '<leader>ts', gitsigns.toggle_signs, {desc = "Toggle Git signs"})

				map_key('n', ']c', function()
					if vim.wo.diff then
						vim.cmd.normal({']c', bang = true})
					else
						gitsigns.nav_hunk('next')
					end
				end, {desc = "Next hunk"})
				map_key('n', '[c', function()
					if vim.wo.diff then
						vim.cmd.normal({'[c', bang = true})
					else
						gitsigns.nav_hunk('prev')
					end
				end, {desc = "Prev hunk"})

				map_key('n', '<leader>hp', gitsigns.preview_hunk, {desc = "View hunk"})
				map_key('n', '<leader>hP', gitsigns.preview_hunk_inline, {desc = "View hunk inline"})
				map_key('n', '<leader>hd', gitsigns.diffthis, {desc = "Diff hunk"})

				-- Actions
				map_key('n', '<leader>hs', gitsigns.stage_hunk, {desc = "Stage hunk"})
				map_key('n', '<leader>hr', gitsigns.reset_hunk, {desc = "Reset hunk"})

				-- Toggles
				map_key('n', '<leader>tb', gitsigns.toggle_current_line_blame)
				map_key('n', '<leader>tw', gitsigns.toggle_word_diff)
			end,
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

	-- TODO: WTF is Oil.nvim?
	{ 'stevearc/oil.nvim',
		opts = {
			default_file_explorer = true,  -- Replace netrw
		},
	},

	-- Nvim Tree seems faster than Neotree (for now)
	-- TODO: Check CHADTree https://github.com/ms-jpq/chadtree
	{ 'nvim-tree/nvim-tree.lua',
		-- TODO: Fix highlight groups (undercurl is just bad (NvimTreeSymlink)
		tag = 'v1.0',
		keys = {
			{"<F2>", "<CMD>NvimTreeToggle<CR>", desc = "NvimTree" },
			{"<S-F2>", "<CMD>NvimTreeFindFile<CR>", desc = "Find file in NvimTree" },
			{"<LEADER>ff", function() require('nvim-tree.api').tree.find_file({open=true, focus=false}) end, desc = "Find file in NvimTree" },
		},
		cmd = {"NvimTreeOpen", "NvimTreeToggle"},
		opts = {
			git = {
				enable = false,
			},
			view = {
				width = 45,
			},
			filters = {
				dotfiles = true,
			},
			modified = { enable = true },
			diagnostics = {
				enable = true,
				show_on_dirs = true,
				show_on_open_dirs = true,
				icons = {
					hint = "h",
					info = "i",
					warning = "w",
					error = "e",
				},
			},
			renderer = {
				add_trailing = true,
				highlight_git = false,
				highlight_modified = 'all',  -- Value can be `"none"`, `"icon"`, `"name"` or `"all"`
				symlink_destination = false,
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
		opts = {
			expand = 1,
			spec = {},
		},
	},

	{ 'lukas-reineke/indent-blankline.nvim',
		main = 'ibl',
		keys = {
			{ '<leader>tg', '<cmd>IBLToggle<cr>', desc = "Toggle Indent guides" },
		},
		cmd = "IBLToggle",
		---@module "ibl"
		---@type ibl.config
		opts = {
			enabled = false,  -- disabled since the key that loads the plugin also enables it
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
			{ '<leader>mo', '<cmd>Telescope aerial<cr>', desc = 'Telescope overview' },
			{ '<leader>pp', '<cmd>Telescope project<cr>', desc = 'Telescope projects' },
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
		version = '2.5.0',
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

			-- I can't get the new config via nvim 0.11 (vim.lsp.config/.enable) without
			-- every lsp trying to attach to every file I'm opening. Staying with
			-- nvim-lspconfig (lspconfig[].setup) for now.

			lspconfig.rust_analyzer.setup({
				-- TODO: Prevent opening on wrong filetype
				cmd = { vim.fn.expand('~/') .. "/.cargo/bin/rustup", "run", "stable", "rust-analyzer" },
				settings = {
					["rust-analyzer"] = {},
				},
			})

			vim.lsp.enable('pyright')
			lspconfig.pyright.setup({
				cmd = {"/opt/homebrew/bin/pyright-langserver", "--stdio"},
				-- https://github.com/neovim/nvim-lspconfig/issues/500
				before_init = function(_, config)
					config.settings.python.pythonPath = get_python_path(config.root_dir)
				end,
			})

			lspconfig.lua_ls.setup()

			lspconfig.clangd.setup({
				cmd = { 'clangd' },
			})

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

					local function table_update(target, source)
						for k,v in pairs(source) do
							target[k] = v;
						end

						return target;
					end

					-- Enable completion triggered by <C-x><C-o>
					-- vim.bo[ev.buf].omnifunc = 'v:lua.lim.lsp.omnifunc'

					-- Buffer local mappings.
					--vim.keymap.set('n', 'gi', vim.lsp.buf.signature_help, bindopts)
					vim.keymap.set('n', 'go', vim.lsp.buf.hover, table_update({desc='LSP Hover'}, bindopts))
					vim.keymap.set('n', 'gO', vim.lsp.buf.code_action, table_update({desc='LSP Code Actions'}, bindopts))

					local builtin = require('telescope.builtin')
					vim.keymap.set('n', 'gl', builtin.lsp_implementations, table_update({ desc = 'LSP Implementations (telescope)' }, bindopts))
					vim.keymap.set('n', 'gL', builtin.lsp_references, table_update({desc = 'LSP References (Telescope)'}, bindopts))
					vim.keymap.set('n', 'gd', builtin.lsp_definitions, table_update({desc='LSP Definitions (Telescope)'}, bindopts))
					vim.keymap.set('n', 'gD', builtin.lsp_type_definitions, table_update({desc='LSP Type Definitions (Telescope'}, bindopts))
					vim.keymap.set('n', '<leader>ms', builtin.lsp_workspace_symbols, table_update({desc='LSP Buffer Symbols'}, bindopts))
					vim.keymap.set('n', '<leader>mS', builtin.lsp_workspace_symbols, table_update({desc='LSP Workspace Symbols'}, bindopts))
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
		version = '0.10.0',
		lazy = false,  -- Treesitter doesn't work with lazy load according to readme
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

vim.api.nvim_set_keymap('n', '<LEADER>fp', '<CMD>e $MYVIMRC<CR>', { silent = true, desc = 'Edit $MYVIMRC' })

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

-- Fix issue where some plugin sets the conceallevel which causes
-- parts of help-files to be concealed
vim.api.nvim_create_autocmd({ 'FileType' }, {
	pattern = "help",
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- TODO: Debug-setup in nvim via DAP https://tamerlan.dev/a-guide-to-debugging-applications-in-neovim/
