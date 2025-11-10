# ai-docstring.nvim
A plugin for generating docstrings with ollama.
This plugin i still in its infancy and lacks most of its features.

This plugin will attempt to write a docstring for the function at the cursors position.

## Prerequisites
* [Ollama](https://github.com/ollama/ollama)
* Mistrel:7b - _This can be chanded with opts.ai.model_

## Supported languages
* C
* C++
* LUA
* Python
  This list will be expanded.

## Installation
### Lazy
```
{
    "kr4nkenwagen/ai-docstring.nvim"
}
```

## Configuration
```
require("ai-docstring").setup({
    key = "<leader>od",
    accept_key = "<leader>",
    decline_key = "q",
    ai = {
        model = "mistral:7b",
        system = "system prompt",
        serve = true
    }
})
```

## License

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://jon-jennemann.mit-license.org)
