# LDoc-DocsetGenerator
A lua script to create a Zeal/Dash compatible docset from LDoc documentation

## Usage:

1) Edit config.lua to edit parameters.
2) lua docsetGenerator.lua

## Requirements:

- LDoc
- sqlite3
- penlight (loadable)

## Notes:

It ends up pulling config.lua from the current folder, so you can run it from a different working directory to get it to use a different config.
