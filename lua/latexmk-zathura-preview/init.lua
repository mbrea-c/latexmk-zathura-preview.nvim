local M = {}

local _data = { workspace_previewers = {}, workspace_builds = {} }

function M.build_and_preview()
  M.build()
  M.preview()
end

function M.preview()
  local filename = "main.pdf"
  local workspace = M.find_workspace()
  local preview_id = _data.workspace_previewers[workspace]
  local files = vim.fs.find(filename, { path = workspace })
  if #files > 0 then
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local synctex_fwd_arg = " --synctex-forward=" .. row .. ":" .. col .. ":" .. vim.fn.bufname()
    if preview_id == nil then
      _data.workspace_previewers[workspace] = vim.fn.jobstart("zathura" .. synctex_fwd_arg .. " " .. files[1])
    else
      local preview_status = vim.fn.jobwait({ preview_id }, 0)[1]
      if preview_status ~= -1 then
        _data.workspace_previewers[workspace] = vim.fn.jobstart("zathura" .. synctex_fwd_arg .. " " .. files[1])
      else
        print("Preview already running")
      end
    end
    local zathura_job_id = _data.workspace_previewers[workspace]
    local zathura_pid = vim.fn.jobpid(zathura_job_id)
    local command = "zathura" .. " --synctex-pid=" .. zathura_pid .. synctex_fwd_arg .. " " .. files[1]
    vim.fn.jobstart(command)
  end
end

function M.find_workspace()
  local latexmkrc_find_results = vim.fs.find("latexmkrc", { upward = true })
  local workspace = nil
  if #latexmkrc_find_results > 0 then
    workspace = vim.fs.dirname(latexmkrc_find_results[1])
  end
  return workspace
end

function M.build()
  local workspace = M.find_workspace()
  local build_id = _data.workspace_builds[workspace]
  if build_id == nil then
    _data.workspace_builds[workspace] = vim.fn.jobstart("latexmk", { cwd = workspace })
  else
    local build_status = vim.fn.jobwait({ build_id }, 0)[1]
    if build_status ~= -1 then
      _data.workspace_builds[workspace] = vim.fn.jobstart("latexmk", { cwd = workspace })
    else
      print("Build already running")
    end
  end
end

return M
