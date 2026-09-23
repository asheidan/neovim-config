vim.api.nvim_create_user_command("TagStackToggle", function()
	require("tagstack").toggle_stack_window()
end, {})
