[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://jon-jennemann.mit-license.org)

# ai-docstring.nvim
A plugin for generating docstrings with ollama.
This plugin i still in its infancy and lacks most of its features.

This plugin will attempt to write a docstring for the function at the cursors position.

## Prerequisites
* [Ollama](https://github.com/ollama/ollama)
* Mistrel:7b - _This can be chanded with opts.ai.model_
* [Nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

## Natively supported languages
* C
* C++
* LUA
* Python


  This list will be expanded.

## Installation
### Lazy
``` lua
{
    "kr4nkenwagen/ai-docstring.nvim"
}
```

## Configuration
``` lua
require("ai-docstring").setup({
    key = "<leader>od",
    accept_key = "<leader>",
    decline_key = "q",
    renew_key = "r"
    ai = {
        model = "mistral:7b",
        prompt = "system prompt",
        serve = true
    }
})
```
### opt.ai.
This will allow the user to set their own system prompt. use the following variables:

| Name      | Definition                                                                      |
| --------- | ------------------------------------------------------------------------------- |
| $LANG     | Filetype.(python, c, cpp, lua)                                                  |
| $TEMPLATE | This supplies a template to the LLM for how the docstring should be structured. |
| $FUNC     | Adds function body to the prompt                                                |

### Adding custom languages
To add more languages you can add them to opt.languages. You will require to add three fields to the object. The key in the languages table needs to be identical to `vim.bo.filetype`,
| Name         | Definition                                                                                                                                                  |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| docstring    | A template for how the docstring should be structured.                                                                                                      |
| get_function | A function that returns start_line and end_line of the function.                                                                                            |
| post_process | a function that takes a string array and returns it. Here you can do formatting and set the cursor in the buffer where you want the docstring to be placed. |

_example_
``` lua
opt.languages["lua"] = {
  docstring = [[ 
  --- {{Brief description}}
  -- @tparam {{typed arg tupe}} {{typed arg name}} {{typed arg description}}
  -- @param {{arg tupe}} {{arg name}} {{arg description}}
  -- @treturn {{typed return type}} {{typed return description}}
  -- @return {{return description}}
  ]],

  get_function = function()
    local node = vim.treesitter.get_node({ pos = vim.api.nvim_win_get_cursor(0) })
    while node do
      if node:type():match("function_declaration") then
        break
      end
      node = node:parent()
    end
    if node == nil then
      return nil, nil
    end
    local start_line, start_col, end_row, end_col = node:range()
    local line_count = end_row - start_line
    return start_line, line_count
  end,

  post_process = function(docstring)
    for i = #docstring, 1, -1 do
      if docstring[i] == "" then
        table.remove(docstring, i)
      end
    end
    local buf = vim.api.nvim_get_current_buf()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(buf, row, row, true, { "" })
    vim.api.nvim_win_set_cursor(0, { row, 0 })
    for i = #docstring, 1, -1 do
      local line = docstring[i]
      if string.find(line, "```") or #line == 0 then
        table.remove(docstring, i)
      end
    end
    return docstring
  end
}
```
