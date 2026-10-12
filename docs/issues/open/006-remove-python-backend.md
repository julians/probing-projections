# 006 Remove the Python backend

Phase: 0 · Clean up

## Why
Since 001 everything runs in the browser; `server/` is dead code.

## Tasks
- [ ] Delete `server/`, `Procfile`, `requirements.txt`
- [ ] Delete `.vscode/settings.json` (only points to `venv/bin/python`) and the local `venv/`
- [ ] Drop the Python entries from `.gitignore`
- [ ] Keep a test dataset: `server/iris.csv` (with classes) is useful for 011/012, move it
  somewhere like `web/test/fixtures/`

## Notes

## Done
