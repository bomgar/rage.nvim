local rage = {}

local function find_meme_directory()
	-- Replace 'unique_identifier_within_meme_dir' with the name of a file or subdirectory within your 'meme' directory
	local matches = vim.api.nvim_get_runtime_file('meme/rage-memes.file', false)
	if matches and #matches > 0 then
		-- This will give you the path to the 'unique_identifier_within_meme_dir'
		local path_to_unique_identifier = matches[1]
		-- Now, trim the 'unique_identifier_within_meme_dir' part to get the path to the 'meme' directory
		local meme_directory = path_to_unique_identifier:sub(1,
			#path_to_unique_identifier - #'/rage-memes.file')
		return meme_directory
	else
		print("Could not find the 'meme' directory.")
		return nil
	end
end

local function list_files_in_directory(dir)
	local files = {}
	local handle, err = vim.loop.fs_scandir(dir)
	if handle then
		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then break end
			if string.find(name, "meme$") ~= nil and type == 'file' then
				table.insert(files, dir .. "/" .. name)
			end
		end
	else
		error('Error reading directory: ' .. err)
	end
	return files
end

rage.rage = function(opts)
	opts = opts or {}
	local meme_dir = find_meme_directory()
	print("Meme directory found at: " .. meme_dir)
	local files = list_files_in_directory(meme_dir)

	vim.ui.select(
		files,
		{
			prompt = "meme",
			format_item = function(filepath)
				local filename = filepath:match("^.+/(.+)$") or filepath
				local display_name = filename:gsub("%.([^%.]+)$", ""):gsub("_", " ")
				return display_name
			end,
		},
		function(filename)
			-- Read the file content
			local file_content = vim.fn.readfile(filename)

			-- Get the current buffer and cursor position
			local bufnr = vim.api.nvim_get_current_buf()
			local cursor_pos = vim.api.nvim_win_get_cursor(0)

			-- Insert the file content at the current cursor position
			vim.api.nvim_buf_set_lines(bufnr, cursor_pos[1], cursor_pos[1], false, file_content)
		end
	)
end

return rage
