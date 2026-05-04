vim.opt.background = 'light'

if vim.g.neovide then
	-- fonts set in ~/.config/neovide/config.toml
	vim.api.nvim_set_keymap('n', '<leader>fP', '<cmd>e $HOME/.config/neovide/config.toml<cr>', { silent = true, desc = 'Edit neovide.toml' })

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
else
	vim.opt.guifont = 'ProFontIIx Nerd Font,ProFontIIx:h9'
	--vim.opt.guifont = 'Fira Code:h11'
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

	-- { 'Bekaboo/dropbar.nvim', opts={bar={enable=false}} },  -- Breadcrumbs at the top of the window, seems unstable
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

	-- { 'LhKipp/nvim-nu',
	-- 	enabled = false, -- This doesn't seem to work, TSInstall fails
	-- 	--build = ':TSInstall nu',
	-- 	opts = {},
	-- },

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
			filters = {
				dotfiles = true,
			},
			renderer = {
				add_trailing = true,
				highlight_git = false,
				group_empty = true,
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

	-- Undo-tree
	{ "y3owk1n/time-machine.nvim",
		-- https://github.com/y3owk1n/time-machine.nvim
		enabled = false,
		version = "*", -- Use tagged releases
		init = function()  -- Always run
			vim.opt.undofile = false  -- Don't persist undo-tree
			-- TODO: What to do with the undodir? The default seems OK for me...
			--vim.opt.undodir = vim.fn.expand("~/.undodir") -- suggested by author
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			ignore_filesize = 512 * 1024,  -- Do not store undo for larger than 512kB
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
		tag = '0.1.5',  -- v0.1.9 is released and next verified version
		lazy = true,
		dependencies = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-fzf-native.nvim',  -- Native sorting and allows fzf-syntax
				build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install',
			},
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

			telescope.load_extension('fzf')
			telescope.load_extension('project')
			telescope.load_extension('aerial')
		end,
		cmd = { 'Telescope' },
		keys = {
			{ '<leader><space>', '<cmd>Telescope find_files<cr>', desc = 'Telescope find_files' },
			{ '<leader>bb', '<cmd>Telescope buffers<cr>', desc = 'Telescope buffers' },
			{ '<leader>mo', '<cmd>Telescope aerial<cr>', desc = 'Telescope overview' },
			{ '<leader>pp', '<cmd>Telescope project<cr>', desc = 'Telescope projects' },
			{ '<leader>hh', '<cmd>Telescope help_tags<cr>', desc = 'Telescope helptags' },
		},
	},

	-- TODO: Take a look at a plugin that makes it easier to integrate with Obsidian
	--       - Telekasten.nvim - https://github.com/nvim-telekasten/telekasten.nvim
	--       - Obsidian.nvim   - https://github.com/obsidian-nvim/obsidian.nvim

	{ 'jameswolensky/marker-groups.nvim',
		--dependencies = { 'nvim-lua/plenary.nvim' },
		version = "v1.1.0",
		lazy = true,
		cmd = {
			'MarkerGroupsCreate',
			'MarkerGroupsList',
			'MarkerGroupsSelect',
			'MarkerGroupsView',
			'MarkerGroupsRename',
			'MarkerGroupsDelete',

			'MarkerAdd',
			'MarkerRemove',
			'MarkerList',
		},
		keys = {
			{ '<leader>mmv', desc='Toggle drawer marker viewer' },

			{ "<leader>mma", mode = { "n", "v" }, desc = "Add marker" },
			{ "<leader>mme", desc = "Edit marker at cursor" },
			{ "<leader>mmd", desc = "Delete marker at cursor" },
			{ "<leader>mml", desc = "List markers in buffer" },
			{ "<leader>mmi", desc = "Show marker at cursor" },

			{ "<leader>mmgc", desc = "Create marker group" },
			{ "<leader>mmgs", desc = "Select marker group" },
			{ "<leader>mmgl", desc = "List marker groups" },
			{ "<leader>mmgr", desc = "Rename marker group" },
			{ "<leader>mmgd", desc = "Delete marker group" },
			{ "<leader>mmgi", desc = "Show active group info" },
			{ "<leader>mmgb", desc = "Create group from git branch" },
		},
		opts = {
			picker = 'vim',
			keymaps = { prefix = "<leader>mm" },
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
		version = '2.5.0',
		dependencies = {
			-- Neodev has been deprecated and replaced by lazydev
		},
		config = function()
			-- Inspirational setup
			-- https://github.com/AstroNvim/AstroNvim

			local function get_python_path(workspace)
				if vim.env.VIRTUAL_ENV then
					return vim.fn.resolve(vim.env.VIRTUAL_ENV .. '/bin/python')
				end

				local match = vim.fn.glob(vim.fn.resolve(workspace .. '/.venv'))
				if match ~= '' then
					return vim.fn.resolve(match .. 'bin/python')
				end

				return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
			end

			-- Article about configuring lsp in nvim 0.11 https://blog.diovani.com/technology/2025/06/13/configuring-neovim-011-lsp.html
			-- Article about nvim lsp https://vonheikemen.github.io/devlog/tools/neovim-lsp-client-guide/
			-- Nvim documentation about configure lsp on attach https://neovim.io/doc/user/lsp.html#lsp-attach

			vim.lsp.config('*', {
				root_markers = { '.git', '.jj' },
			})

			local lsp_configs = {
				{ 'clangd' },
				{ 'lua_ls', {
					cmd = ((vim.fn.has('macunix') == 1) and {"/opt/homebrew/bin/lua-language-server"} or nil),
				} },
				{ 'pyright', {
					cmd = ((vim.fn.has('macunix') == 1) and {"/opt/homebrew/bin/pyright-langserver", "--stdio"} or nil),
					-- https://github.com/neovim/nvim-lspconfig/issues/500
					before_init = function(_, config)
						config.settings.python.pythonPath = get_python_path(config.root_dir)
					end,
				} },
				{ 'rust_analyzer', {
					cmd = { vim.fn.expand('~/') .. ".cargo/bin/rustup", "run", "stable", "rust-analyzer" },
				} },
			}

			for _, lsp_config in pairs(lsp_configs) do
				-- Unpack will probably move to table.unpack in lua 5.2
				local name, config = unpack(lsp_config)

				vim.lsp.enable(name)
				if config then
					vim.lsp.config(name, config)
				end
			end

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
					vim.keymap.set('n', 'gl', builtin.lsp_implementations, table_update({desc = 'LSP Implementations (telescope)'}, bindopts))
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
	-- { 'nvim-treesitter/nvim-treesitter-textobjects' },  -- Look at this in the future when this actually works (2025-11-20)
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
