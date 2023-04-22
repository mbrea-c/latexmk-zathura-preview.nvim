# latexmk-zathura-preview.nvim

Opinionated LaTeX previewer plugin using zathura for Neovim.
_SyncTeX_ forwards and backwards syncing are supported and enabled by default.
Assumptions:

- `latexmk` is used for building the project, and a `latexmkrc` file is
  present in the root directory of the project/workspace. This `latexmkrc` file
  must have enabled synctex. Example `latexmkrc` that I tend to use:

  ```perl
  # vim: filetype=perl

  # Ensure custom cls file is found
  ensure_path( 'TEXINPUTS', './cls//' );
  # Ensure custom sty file is found
  ensure_path( 'TEXINPUTS', './sty//' );
  # Ensure bib file is found
  ensure_path( 'TEXINPUTS', './bib//' );
  # Ensure source files are found
  ensure_path( 'TEXINPUTS', './src/' );

  $pdf_mode = 1; # pdflatex as defualt
  $aux_dir = "aux";
  $emulate_aux = 1;
  $out_dir = "out";

  # For synctex
  $lualatex = 'lualatex -interaction=nonstopmode -synctex=1 --shell-escape';
  $pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 -shell-escape';
  $pdf_previewer = "start zathura --unique";

  @default_files = ('src/main.tex', 'src/main_dtalc.tex');
  ```

- The target output file is called `main.pdf`. This will be configurable
  soon, when I have time to get around to it :).
- The `zathura` PDF viewer is installed in your system.
- `nvr` is installed in your system.

## Installation and configuration

### Using lazy.nvim

```lua
return {
  "mbrea-c/latexmk-zathura-preview.nvim",
  config = function()
    local ltx = require("latexmk-zathura-preview")

    local function set_keymaps()
      local function opts(desc)
        return { desc = desc }
      end

      vim.keymap.set("n", "<localleader>ll", ltx.build_and_preview, opts("Build and preview latexmk project"))
    end

    local augroup = vim.api.nvim_create_augroup("LatexmkZathuraPreview", { clear = true })
    vim.api.nvim_create_autocmd("Filetype", {
      pattern = "latex",
      group = augroup,
      callback = set_keymaps,
    })
  end,
}
```

## Usage

If configured as in the installation example, pressing `<localleader>ll` will
build the project and open a preview of the output in a zathura instance, with
the line corresponding to the where the Neovim cursor is placed highlighted. If a
zathura instance already exists, the line will be highlighted in that instance.

In the zathura instance opened thus, you can press CTRL+Left click to navigate
to the corresponding latex source for the text you clicked in your Neovim buffer.
