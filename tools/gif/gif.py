import subprocess

from sys import argv
from math import ceil, sqrt
from wand import image as wandImage
from PIL import Image

size = 2048
output = Image.new("RGBA", (size, size), color="black")


def computeSpritesheet():
    """
    Compute a GIF into a spritesheet.
    """
    image = Image.open(gifPath)

    rows = ceil(sqrt(image.n_frames))
    frameSize = ceil(size / rows)

    print("Frames", image.n_frames)
    print("Resolution", frameSize)
    print("Rows", rows)

    for i in range(0, rows * rows):
        image.seek(i if i < image.n_frames else image.n_frames - 1)
        resize = image.resize((frameSize, frameSize))
        x = int(int(i % rows) * frameSize)
        y = int(int(i / rows) * frameSize)
        output.paste(resize, (x, y))


def saveToIWI():
    """
    Save image to IWI.
    """
    output.save("output/image.png")
    with wandImage.Image(filename="output/image.png") as image:
        image.compression = "dxt5"
        image.save(filename="output/image.dds")
        subprocess.call(["dds2iwi.exe", "output/image.dds"])


def main():
    """
    Program entry.
    """
    if len(argv) < 2:
        print("Usage: gif <path>")
        exit(-1)

    global gifPath
    gifPath = argv[1]

    computeSpritesheet()
    saveToIWI()


if __name__ == "__main__":
    if len(argv) < 2:
        print("usage: gif <filePath>")
        exit(-1)
    main()
