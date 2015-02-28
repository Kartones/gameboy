GBSlides
========

# Intro #

**Note:** Slides/Content is not fully done yet, but the viewer works (although bugs might exist).

GBSlides is a simple GameBoy Powerpoint-like slides viewer I built to learn how programming the GameBoy in Z80 Assembler was
back in the early 90s. As building a game is quite time consuming and I was going to give a talk at an event, I decided to
give the talk using a GB emulator and tool built by me.

The result is `gbslides.asm` file, a small slide viewer. It uses gameboy Maps/Backgrounds to load slides on them and display one
at a time. As editing inside a Tile Editor like GBTB is tiring for simple text, I also made a script that transforms from
plain text files to .INC files that have Assembler code defining the backgrounds (BG had no "files", everything was inside the ROM).

Small demo:
![Sample presentation inside VisualBoyAdvance](http://www.comomonos.com/up/wip_25_feb_2015.gif)

The "real" presentation is available at:
[slides.kartones.net](http://slides.kartones.net/023.htm)

And as was hard to gather all tools and documentation, I've setup a zip containing a nice development toolset at:
[kartones.net/Downloads/gbdevpack.zip](http://kartones.net/Downloads/gbdevpack.zip)

# Usage #

- First you must compile the source code to generate a binary GB ROM file. I have used the RGBDS compiler:

```
rgbasm -o gbslides.o gbslides.asm
rgblink -o gbslides.gb gbslides.o
rgbfix -v -p 0 gbslides.gb
```

- Then, simply load the ROM into a Gameboy emulator (or transfer to a real cartidge). A button goes to the previous slide,
B button advances to next one.

- Format for slides is quite easy, I recommend checking the `asciitomapasm.rb` Ruby script and tileset.gbr to see which
characters and symbols are available to convert to Tiles.

- Each slide gets transformed into Map/BG data (backgrounds are not animated, composed by tiles and very easy to handle).

- To add or remove slides, or edit their content, just edit the `txt` files inside `\slides` folder, then run `ruby asciitomapasm.rb`
from this project's root, then edit