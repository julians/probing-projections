# 006 Remove the Python backend

Phase: 0 · Clean up

## Why
Since 001 everything runs in the browser; `server/` is dead code.

## Tasks
- [x] Delete `server/`, `Procfile`, `requirements.txt`
- [x] Delete `.vscode/settings.json` (only points to `venv/bin/python`) and the local `venv/`
- [x] Drop the Python entries from `.gitignore`
- [x] Keep a test dataset: `server/iris.csv` (with classes) is useful for 011/012, move it
  somewhere like `web/test/fixtures/`

## Notes

## Done
- 34b641d: deleted `server/`, `Procfile`, `requirements.txt`, `.vscode/settings.json` and the
  local `venv/`; dropped `*.pyc` and `venv` from `.gitignore`. `iris.csv` is now
  `web/test/fixtures/iris.csv`.
- This also clears the 34 Dependabot alerts on `requirements.txt`. The 6 alerts on
  `web/package.json` (grunt, handlebars) were already fixed and should close on the next scan.
