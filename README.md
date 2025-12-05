[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://jon-jennemann.mit-license.org)

# ai-docstring.nvim
A plugin for generating docstrings with ollama.
This plugin i still in its infancy and lacks most of its features.

This plugin will attempt to write a docstring for the function at the cursors position.

## Usage
Put your cursor inside a function and press `<Leader>od`. A scratch pad will appear. Ollama will pip output to it and you can edit it. Once you are happy with the docstring, press `<leader>` to apply it to your function.

### Keybinds inside the scratch pad
* `<Leader>` closes scratch pad and applies the generated docstring.
* `r` Clears scratch pad and generates a new docstring.
* `q` Discoards docstring and closes scratch pad.


_These keybinds can be configured inside `opts`_

## Prerequisites
* [Ollama](https://github.com/ollama/ollama)
* Mistrel:7b - _This can be changed with opts.ai.model_
* [Nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

## Natively supported languages
* C
* C++
* C#
* Elixir
* Go
* Haskell
* Java
* Javascript
* Julia
* Kotlin
* Lua
* Perl
* PHP
* Python
* Ruby
* Rust
* Swift
* Typescript

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
    key = "<leader>o",
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
### opt.ai.prompt
This will allow the user to set their own system prompt. Use the following variables:

| Name      | Definition                                                                      |
| --------- | ------------------------------------------------------------------------------- |
| $LANG     | Filetype.(python, c, cpp, lua)                                                  |
| $TEMPLATE | This supplies a template to the LLM for how the docstring should be structured. |
| $FUNC     | Adds function body to the prompt                                                |

### Adding custom languages
To add more languages you can add them to opt.languages. The key in the languages table needs to be identical to output of `:lua print(vim.bo.filetype)`. The following members are required.
| Name         | Definition                                                                                                                                                  |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| docstring    | A template for how the docstring should be structured.                                                                                                      |
| get_function | Function that returns start_line and end_line of the function.                                                                                              |
| post_process | Function that takes a string array and returns it. This runs after AI generation. You can format or cleanup the text here.                                  |
| set_cursor   | In this function you set where the docstring will be inserted. If this function is empty the docstring will be placed above function declaration.           |

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
    end_row = end_row + 1
    return start_line, end_row
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
