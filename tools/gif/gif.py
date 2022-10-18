from sys import argv
from math import ceil, sqrt
from PIL import Image

size = 2048
output = Image.new("RGBA", (size, size), color="black")


def computeSpritesheet():
    image = Image.open(argv[1])

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


def main():
    computeSpritesheet()
    output.save("output.dds", "DDS")


if __name__ == "__main__":
    if len(argv) < 2:
        print("usage: gif <filePath>")
        exit(-1)
    main()
