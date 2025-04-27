# igc2kmz batch converting scripts

## About

Scripts for an [igc2kmz.py3 project](https://github.com/Dmitry-Borodin/igc2kmz.py3) to convert all *.igc files in dir to *.kmz

It adds coloring for lift/sink, calculate thermals, altitude points et.c. so it's very handy to analyze tracks in google earth afterwards.


Based on [Ivan Kravchenko's gists](https://gist.github.com/Iv).

I think repository makes it easier to find and contribute.
Windows script not tested yet.

## Installation
* Install Python 3
* Download this repo 'git clone --recurse-submodules git@github.com:Dmitry-Borodin/igc2kmz-batch-scripts.git'
* For Windows update path in igc2kmz.bat file if needed:
- igc2kmz.reg -update path to the igc2kmz.bat file and add to registry
- igc2kmz.bat - update path to igc2kmz project and python (downloaded above)


## Usage

[contributions are welcome, especially in this part]

1)Create subfolders for each group member
2)Put tracks and color.txt (optional) files inside.
3)Run the script

Happy flights review on Google Earth.


# Other options

https://spasutto.github.io/igc2kmz/igc2kmz.html

telegram @igc2kmz_bot 
