vim.opt.guifont = 'ProFontIIx:h9'
--vim.opt.guifont = 'Fira Code:h11'
vim.opt.background = 'light'

local terminal_vim = "vim" == vim.v.argv[1]
if terminal_vim then
	vim.opt.background = 'dark'
else
	vim.opt.background = 'light'
end

-- Temporarily set this until i fix neovide fonts
vim.opt.termguicolors = true

if vim.g.neovide then
	-- Adding padding seems to cause issues where the actual text isn't aligned on
	-- pixels which causes all text in the window to look blurry.
	vim.g.neovide_padding_left = 0
	vim.g.neovide_padding_right = 0
	vim.g.neovide_padding_top = 0
	vim.g.neovide_padding_bottom = 0

	-- vim.g.neovide_refresh_rate = 60  -- This is only used when vsync is turned off
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

end

vim.opt.title = true
-- Default is similar to vim.opt.titlestring = '%t%( %M%)%( (%{expand("%:~:h")})%)%a - Nvim'
-- Nvim - ~/.config / nvim/init.lua
vim.opt.titlestring = "Nvim - %{fnamemodify(getcwd(), ':~:s_.*/\\([^/]\\+/[^/]\\+\\)_\\1_')} / %{expand('%')}%( %M%)"

vim.opt.cursorline = true

vim.opt.mouse = "nvi"

vim.opt.wildmode = "full:longest"
vim.opt.completeopt = "menu,popup,noinsert"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.linebreak = true

vim.g.mapleader = ' '

vim.api.nvim_create_user_command('Help', 'Telescope help_tags', {})
vim.api.nvim_create_user_command('Tags', 'Telescope tags', {})

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
		-- TODO: Set the cursor to magenta in an after-file
		lazy = false,
		priority = terminal_vim and nil or 1000,
		-- init = function() end,
		config = function()
			vim.g.PaperColor_Theme_Options = {
				language = {
					c = { highlight_builtins = 1 },
					cpp = { highlight_standard_library = 0 },
				},
				theme = {
					default = {
						allow_bold = vim.g.neovide and 1 or 0,
						allow_italic = vim.g.neovide and 1 or 0,
					},
					-- This doesn't work in Neovide and makes no difference in terminal
					--['default.light'] = {
					--	override = {
					--		cursor_fg = { '#eeeeee', '255' },
					--		cursor_bg = { '#ff00ff', '226' },
					--	},
					--},
				},
			}
			if not terminal_vim then
				vim.cmd.colorscheme('PaperColor')
				-- Workaround for ugly separator between splits
				vim.cmd('highlight WinSeparator guifg=#005f87 guibg=#eeeeee')
			end
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
		opts = {},
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

				map_key('v', '<leader>hs', function()
					gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
				end, {desc = "Stage hunk"})
				map_key('v', '<leader>hr', function()
					gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
				end, {desc = "Reset hunk"})

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

	{ 'jakemason/ouroboros',
		dependencies = { 'nvim-lua/plenary.nvim' },
		-- ft = { 'cpp', 'c' },  -- Loading by filetype removes my keybind // 2026-02-26
		keys = {
			{ "<leader>ti", "<cmd>Ouroboros<cr>", ft = {'cpp', 'c'}, desc = "Toggle between header/implementation" },
		},
		cmd = "Ouroboros",
		opts = {
      switch_to_open_pane_if_possible = false,
			extension_preferences_table = {
				c = { h = 2, hpp = 1 },
				h = { c = 2, cpp = 1 },
				cpp = { hpp = 2, h = 1 },
				hpp = { cpp = 2, c = 1 },
				cc = { hh = 2, h = 1},
				hh = { cc = 2, c = 1},
				cxx = { hxx = 2, h = 1 },
				hxx = { cxx = 2, c = 1 },
			},
		},
	},

	{ 'jameswolensky/marker-groups.nvim',
		-- TODO: Fix delay caused by Telescope being loaded at the same time
		dependencies = { 'nvim-lua/plenary.nvim' },
		opts = {
			keymaps = {
				prefix = '<leader>n',
			},
			picker = 'telescope',
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
			{ 'nvim-telescope/telescope-fzf-native.nvim',
				build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install'
			},
			-- 'stevearc/aerial.nvim',  -- For Aerial, installation and config defined separately
		},
		config = function()
			local telescope = require('telescope')
			local actions = require('telescope.actions')

			telescope.setup({
				defaults = {
					file_ignore_patterns = { "^venv", "^__pycache__" },
					layout_strategy = "vertical",
					layout_config = {
						height = 0.95,
						width = 0.95,
					},
				},
				pickers = {
					buffers = {
						mappings = {
							n = {
								["<c-d>"] = actions.delete_buffer,  -- actions.move_to_top
							},
							i = {
								["<c-d>"] = actions.delete_buffer,  -- actions.move_to_top
							},
						},
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
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = 'smart_case',  -- default
					},
					project = {
						base_dirs = {
							{ path = '~/Documents/Projects', max_depth = 2 },
						},
						order_by = 'asc',
						sync_with_nvim_tree = true,
					},
				},
			})

			telescope.load_extension('fzf')
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
		-- TODO: Hitta en commit som funkar
		commit = 'a63d28a9aa59c20a503ce38608fb6bc7cb3842f4',
		lazy = true,
		cmd = {'COQnow', 'COQhelp'},
		dependencies = {
			{ 'ms-jpq/coq.artifacts', branch = 'artifacts' },
		},
		init = function()
			vim.g.coq_settings = { ["display.preview.positions"] = { east = 4, north = 3, south = nil, west = nil } }
		end,
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

			vim.lsp.enable('rust_analyzer')
			vim.lsp.config('rust_analyzer', {
				-- TODO: Prevent opening on wrong filetype
				cmd = { vim.fn.expand('~/') .. "/.cargo/bin/rustup", "run", "stable", "rust-analyzer" },
				settings = {
					["rust-analyzer"] = {},
				},
			})

			--vim.lsp.enable('pyright')
			-- lspconfig.pyright.setup({
			-- 	cmd = {"/opt/homebrew/bin/pyright-langserver", "--stdio"},
			-- 	-- https://github.com/neovim/nvim-lspconfig/issues/500
			-- 	before_init = function(_, config)
			-- 		config.settings.python.pythonPath = get_python_path(config.root_dir)
			-- 	end,
			-- })
			-- TODO: See if Rope needs extra config to work
			vim.lsp.enable('pylsp')

			vim.lsp.enable('lua_ls')

			vim.lsp.enable('clangd')
			vim.lsp.config('clangd', {
				cmd = { 'clangd-20', '--background-index', '--clang-tidy' },
			})

			lspconfig.protols.setup({})

			-- vim.lsp.enable('bitbake_language_server')  -- 0.0.15 is broken, 0.0.16 is not available in pypi

			-- TODO: Add bashls
			-- TODO: Add bitbake-language-server

			-- LSP Configs
			vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { silent = true, desc = 'Display diagnostics' })
			vim.keymap.set('n', '[d', function() vim.diagnostic.jump({count=1,float=true}) end, { silent = true, desc = 'Previous diagnostic' })
			vim.keymap.set('n', ']d', function() vim.diagnostic.jump({count=-1,float=true}) end, { silent = true, desc = 'Next diagnostic' })

			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('UserLspConfig', {}),
				callback = function(ev)
					local bindopts = { noremap = true, silent = true, buffer = ev.buf }

					-- Support for inlay_hint was added in 0.10
					if vim.fn.has("nvim-0.10") == 1 then
						vim.lsp.inlay_hint.enable()
						vim.keymap.set('n', '<leader>th', function () vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { silent = true, desc = 'Toggle inlay Hints' })
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
	{ 'rcarriga/nvim-dap-ui',
		dependencies = {
			'mfussenegger/nvim-dap',
			'theHamsta/nvim-dap-virtual-text',
			'nvim-neotest/nvim-nio',  -- Async IO-support
		},
		config = function()
			local dap = require('dap')
			local dapui = require('dapui')

			-- dap.adapters.gdb = {
			-- 	type = "executable",
			-- 	command = "gdb",
			-- 	args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			-- }

			dap.adapters.cppdbg = {
				id = 'cppdbg',
				type = 'executable',
				command = '/home/eer/.local/share/nvim/daps/cpptools/debugAdapters/bin/OpenDebugAD7',
			}
			dap.configurations.cpp = {
				{
					name = "Launch file (gdb)",
					type = "gdb",
					request = "launch",
					program = function()
						return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
					end,
					args = {}, -- provide arguments if needed
					cwd = "${workspaceFolder}",
					stopAtBeginningOfMainSubprogram = false,
				},
				{
					name = "Launch file (cpptools)",
					type = "cppdbg",
					request = "launch",
					program = function()
						return vim.fn.input{prompt='Path to executable: ', default=vim.fn.getcwd() .. '/', completion='file'}
					end,
					args = {"--gtest_filter=ProfileStorageServiceTest.GetLastTracePeekFailThenFallbackToFinalized", "--gtest_also_run_disabled_tests"},
					cwd = '${workspaceFolder}',
					stopAtEntry = true,
					setupCommands = {
						{
							text = '-enable-pretty-printing',
							description =  'enable pretty printing',
							ignoreFailures = false,
						},
					},
				},
			}

			dapui.setup()
			require('nvim-dap-virtual-text').setup({})

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
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

	{  -- Integration with Zeal
		'KabbAmine/zeavim.vim',
		init = function()
			vim.g.zv_disable_mapping = true
			vim.g.zv_keep_focus = true  -- Need wmctrl installed
		end,
		keys = {
			{ "<leader>mK", "<Plug>Zeavim", mode="n", desc = "Show documentation in Zeal" },
			{ "<leader>mK", "<Plug>ZVVisSelection", mode="v", desc = "Show documentation in Zeal" },
		},
	},

	-- Other colorschemes
	{ 'morhetz/gruvbox',
		lazy = true,
		priority = terminal_vim and 1000 or nil,
		init = function()
			vim.g.gruvbox_bold = 0;
			if terminal_vim then
				vim.cmd.colorscheme('gruvbox')
			end
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
