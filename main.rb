require 'rmagick'
include Magick

$img = ImageList.new("Mosaic.jpeg")
$output = Image.new(120, 120);

def getGrid()
  grid = Draw.new();
  grid.stroke("black");
  for i in 0..2
    grid.line(0, 120 * (i + 1), 480, 120 * (i + 1));
    grid.line(120 * (i + 1), 0, 120 * (i + 1), 480);
  end
  return grid
end

def getPixels(box_row, box_col)
  row = box_row * 12;
  col = box_col * 12;
  pixels = $img.get_pixels(row, col, 12, 12);
  return pixels;
end

def scaleImage(img)
  new_img = Image.new(480, 480);
  for i in 0..(img.rows - 1)
    for j in 0..(img.columns - 1)
      pixel = img.get_pixels(i, j, 1, 1);
      pixels = Array.new(1600, pixel[0]);
      new_img.store_pixels(i * 40, j * 40, 40, 40, pixels)
    end
  end
  return new_img;
end

grid = getGrid();

mdFile = File.new("output/mosaic.tex", "w");
if mdFile
  mdFile.syswrite("\\documentclass{article}\n
  \\usepackage{graphicx}\n
  \\title{Mosaic}\n
  \\begin{document}\n
  \\maketitle\n
  \\newpage\n");

  for i in 0..7
    for j in 0..7
      pixels = getPixels(i, j);
      output = Image.new(12, 12);
      output.store_pixels(0, 0, 12, 12, pixels);
      output = scaleImage(output);
      grid.draw(output);

      mdFile.syswrite("
      \\clearpage
      \\begin{figure}
      \\includegraphics[width=\\linewidth]{output/#{j}#{i}.jpeg}
      \\caption{(#{j}, #{i})}
      \\label{fig:(#{j}, #{i})}
      \\end{figure}\n");
      output.write("output/#{j}#{i}.jpeg");
    end
  end
  mdFile.syswrite("\\end{document}\n");
  mdFile.close
else
  puts "output/pdf.tex doesn't exist.\n"
end
