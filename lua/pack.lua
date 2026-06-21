-- ============================================================
-- SECTION 3: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
do
	-- [[ Intro to `vim.pack` ]]
	-- `vim.pack` is a new plugin manager built into Neovim,
	--  which provides a Lua interface for installing and managing plugins.
	--
	--  See `:help vim.pack`, `:help vim.pack-examples` or the
	--  excellent blog post from the creator of vim.pack and mini.nvim:
	--  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
	--
	--  To inspect plugin state and pending updates, run
	--    :lua vim.pack.update(nil, { offline = true })
	--
	--  To update plugins, run
	--    :lua vim.pack.update()
	--
	--
	--  Throughout the rest of the config there will be examples
	--  of how to install and configure plugins using `vim.pack`.
	--
	--  In this section we set up some autocommands to run build
	--  steps for certain plugins after they are installed or updated.

	local function run_build(name, cmd, cwd)
		local result = vim.system(cmd, { cwd = cwd }):wait()
		if result.code ~= 0 then
			local stderr = result.stderr or ''
			local stdout = result.stdout or ''
			local output = stderr ~= '' and stderr or stdout
			if output == '' then output = 'No output from build command.' end
			vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
		end
	end

	-- This autocommand runs after a plugin is installed or updated and
	--  runs the appropriate build command for that plugin if necessary.
	--
	-- See `:help vim.pack-events`
	vim.api.nvim_create_autocmd('PackChanged', {
		callback = function(ev)
			local name = ev.data.spec.name
			local kind = ev.data.kind
			if kind ~= 'install' and kind ~= 'update' then return end

			if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
				run_build(name, { 'make' }, ev.data.path)
				return
			end

			if name == 'LuaSnip' then
				if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
				return
			end

			if name == 'nvim-treesitter' then
				if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
				vim.cmd 'TSUpdate'
				return
			end
		end,
	})
end

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- SECTION 4: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
	-- [[ Installing and Configuring Plugins ]]
	--
	-- To install a plugin simply call `vim.pack.add` with its git url.
	-- This will download the default branch of the plugin, which will usually be `main` or `master`
	-- You can also have more advanced specs, which we will talk about later.
	--
	-- For most plugins its not enough to install them, you also need to call their `.setup()` to start them.
	--
	-- For example, lets say we want to install `guess-indent.nvim` - a plugin for
	-- automatically detecting and setting the indentation.
	--
	-- We first install it from https://github.com/NMAC427/guess-indent.nvim
	-- and then call its `setup()` function to start it with default settings.
	vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
	require('guess-indent').setup {}

	-- Here is a more advanced configuration example that passes options to `gitsigns.nvim`
	--
	-- See `:help gitsigns` to understand what each configuration key does.
	-- Adds git related signs to the gutter, as well as utilities for managing changes
	vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
	require('gitsigns').setup {
		signs = {
			add = { text = '+' }, ---@diagnostic disable-line: missing-fields
			change = { text = '~' }, ---@diagnostic disable-line: missing-fields
			delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
			topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
			changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
		},
	}

	-- Useful plugin to show you pending keybinds.
	vim.pack.add { gh 'folke/which-key.nvim' }
	require('which-key').setup {
		-- Delay between pressing a key and opening which-key (milliseconds)
		delay = 0,
		icons = { mappings = vim.g.have_nerd_font },
		-- Document existing key chains
		spec = {
			{ '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
			{ '<leader>t', group = '[T]oggle' },
			{ '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
			{ 'gr', group = 'LSP Actions', mode = { 'n' } },
		},
	}
end

-- ============================================================
-- SECTION 9: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
	-- [[ Configure Treesitter ]]
	--  Used to highlight, edit, and navigate code
	--
	--  See `:help nvim-treesitter-intro`

	-- NOTE: You can also specify a branch or a specific commit
	vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

	-- Ensure basic parsers are installed
	local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
	require('nvim-treesitter').install(parsers)

	---@param buf integer
	---@param language string
	local function treesitter_try_attach(buf, language)
		-- Check if a parser exists and load it
		if not vim.treesitter.language.add(language) then return end
		-- Enable syntax highlighting and other treesitter features
		vim.treesitter.start(buf, language)

		-- Enable treesitter based folds
		-- For more info on folds see `:help folds`
		-- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
		-- vim.wo.foldmethod = 'expr'

		-- Check if treesitter indentation is available for this language, and if so enable it
		-- in case there is no indent query, the indentexpr will fallback to the vim's built in one
		local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

		-- Enable treesitter based indentation
		if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
	end

	local available_parsers = require('nvim-treesitter').get_available()
	vim.api.nvim_create_autocmd('FileType', {
		callback = function(args)
			local buf, filetype = args.buf, args.match

			local language = vim.treesitter.language.get_lang(filetype)
			if not language then return end

			local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

			if vim.tbl_contains(installed_parsers, language) then
				-- Enable the parser if it is already installed
				treesitter_try_attach(buf, language)
			elseif vim.tbl_contains(available_parsers, language) then
				-- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
				require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
			else
				-- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
				treesitter_try_attach(buf, language)
			end
		end,
	})
end
