import subprocess

from sys import argv
from math import ceil, sqrt
from wand import image as wandImage
from PIL import Image

size = 2048
output = Image.new("RGBA", (size, size), color="black")


def computeSpritesheet():
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
    output.save("output/{}.png".format(imageName))
    with wandImage.Image(filename="output/{}.png".format(imageName)) as image:
        image.compression = "dxt5"
        image.save(filename="output/{}.dds".format(imageName))
        subprocess.call(["dds2iwi.exe", "output/{}.dds".format(imageName)])


def main():
    global imageName
    global gifPath

    imageName = argv[1]
    gifPath = argv[2]

    computeSpritesheet()
    saveToIWI()


if __name__ == "__main__":
    if len(argv) < 3:
        print("Usage: gif <name> <path>")
        exit(-1)
    main()
