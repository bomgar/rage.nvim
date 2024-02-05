local telescope = require('telescope')
local pickers = require('telescope.pickers')
local previewers = require('telescope.previewers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local action_state = require('telescope.actions.state')
local actions = require('telescope.actions')

local telescope_rage = {}

local function find_meme_directory()
    -- Replace 'unique_identifier_within_meme_dir' with the name of a file or subdirectory within your 'meme' directory
    local matches = vim.api.nvim_get_runtime_file('meme/telescope-rage-memes.file', false)
    if matches and #matches > 0 then
        -- This will give you the path to the 'unique_identifier_within_meme_dir'
        local path_to_unique_identifier = matches[1]
        -- Now, trim the 'unique_identifier_within_meme_dir' part to get the path to the 'meme' directory
        local meme_directory = path_to_unique_identifier:sub(1,
            #path_to_unique_identifier - #'/telescope-rage-memes.file')
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

local function file_entry_maker(filepath)
    local filename = filepath:match("^.+/(.+)$") or filepath
    local display_name = filename:gsub("%.([^%.]+)$", ""):gsub("_", " ")

    return {
        display = display_name,
        value = filepath,
        ordinal = filename,
        -- Optionally, you can define a custom previewer per entry, but usually, the default previewer is sufficient
    }
end


telescope_rage.rage = function(opts)
    opts = opts or {}
    local meme_dir = find_meme_directory()
    print("Meme directory found at: " .. meme_dir)
    local files = list_files_in_directory(meme_dir)

    pickers.new(opts, {
        prompt_title = 'Rage',
        finder = finders.new_table({
            results = files,
            entry_maker = file_entry_maker,
        }),
        previewer = previewers.vim_buffer_cat.new({}),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                -- Your custom action on selection
                local filename = selection.value

                -- Read the file content
                local file_content = vim.fn.readfile(filename)

                -- Get the current buffer and cursor position
                local bufnr = vim.api.nvim_get_current_buf()
                local cursor_pos = vim.api.nvim_win_get_cursor(0)

                -- Insert the file content at the current cursor position
                vim.api.nvim_buf_set_lines(bufnr, cursor_pos[1], cursor_pos[1], false, file_content)
            end)

            return true
        end,
    }):find()
end

return telescope.register_extension({
    exports = {
        rage = telescope_rage.rage,
    },
})
