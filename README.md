# rage.nvim

Port of my old plugin [helm-rage](https://github.com/bomgar/helm-rage)


Uses vim.ui.select to insert memes.


## Installation

lazy.nvim

```lua
return {
        {
            "bomgar/rage.nvim",
            keys = {
                { "<leader>fr", function() require("rage").rage() end, desc = "rage" }
            }
    }
}
```
