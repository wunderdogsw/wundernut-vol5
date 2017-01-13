import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.stream.IntStream;

public class WinterMessage {
    public static void main(String[] args) throws IOException {
        BufferedImage img = ImageIO.read(new File("static1.squarespace.com.png"));
        int start_left = 139 << 16 | 57 << 8 | 137, start_up = 7 << 16 | 84 << 8 | 19; //Variables just to make main loop clear to read
        int end = 51 << 16 | 69 << 8 | 169;
        int left = 123 << 16 | 131 << 8 | 154;
        int right = 182 << 16 | 149 << 8 | 72;
        int[] directions = {-1, -1 * img.getWidth(), 1, img.getWidth()}; //left, up, right, down
        int[] pixels = img.getRGB(0,0, img.getWidth(), img.getHeight(), null, 0, img.getWidth());
        int[] response = new int[img.getWidth() * img.getHeight() * 3];

        IntStream.range(0, pixels.length).forEach(i -> pixels[i] = pixels[i] & 0xffffff);//Filter out alpha
        IntStream.range(0, pixels.length).filter(i -> (pixels[i] == start_left) || (pixels[i] == start_up))
                .forEach(pixelIndex -> {
                    int direction = pixels[pixelIndex] == start_left ? 0 : 1;
                    response[pixelIndex * 3] = 0xff;//mark start with red
                    while (pixels[pixelIndex] != end) {
                        if (pixels[pixelIndex] == right) direction = ++direction % 4;
                        if (pixels[pixelIndex] == left)
                            direction = (direction + 3) % 4;//-1, but other way around to keep remainder positive
                        pixelIndex += directions[direction];
                        response[pixelIndex * 3 + 1] = 0xff; //and mark rest with green
                    }
                });
        img.getRaster().setPixels(0,0, img.getWidth(), img.getHeight(), response);
        ImageIO.write(img, "png", new File("Merry_Christmas.png"));
    }
}
