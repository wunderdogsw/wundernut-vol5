#!/usr/bin/env bash

# This reads the secret message from the Wundernut as instructed here:
#                                            http://wunder.dog/secret-message-1

ROW_LENGTH=180;

# BEGIN HELPER FUNCTIONS
function draw_up() {
  index=$1;

  pixels[index]=" ";
  while [ "${pixels[index]}" == " " ]; do 
    pixels[index]="@"; 
    index=$(( index - ROW_LENGTH )); 
  done

  # IF WE ENDED IN A COMMAND PIXEL THEN PROCEED ACCORDINGLY
  if [ "${pixels[index]}"   == "L" ]; then 
    draw_left $index;
  elif [ "${pixels[index]}" == "R" ]; then 
    draw_right $index; 
  fi
}

function draw_right() {
  index=$1;

  pixels[index]=" ";
  while [ "${pixels[index]}" == " " ]; do
    pixels[index]="@";
    index=$(( index + 1 ));
  done

  if [ "${pixels[index]}" == "R" ]; then
    draw_down $index;
  elif [ "${pixels[index]}" == "L" ]; then
    draw_up $index;
  fi
}

function draw_down() {
  index=$1;

  pixels[index]=" ";
  while [ "${pixels[index]}" == " " ]; do
    pixels[index]="@";
    index=$(( index + ROW_LENGTH ));
  done

  if [ "${pixels[index]}" == "R" ]; then
    draw_left $index;
  fi
}

function draw_left() {
  index=$1;

  pixels[index]=" ";
  while [ "${pixels[index]}" == " " ]; do
    pixels[index]="@";
    index=$(( index - 1 ));
  done

  if [ "${pixels[index]}" == "R" ]; then 
    draw_up $index
  elif [ "${pixels[index]}" == "L" ]; then
    # TURNING LEFT WHEN GOING TO LEFT MEANS GOING DOWN. 
    # AND SINCE WE'VE NOT SEEN THE FOLLOWING LINE YET WE
    # CAN'T GO DOWN BUT RATHER WE MUST MARK THIS PIXEL
    # WITH OUR OWN INVENTED INSTRUCTION OF 'D' FOR DOWN.
    pixels[index]="D";
  fi
}
# END HELPER FUNCTIONS


# 1) READ PIXELS 
i=0;
for OUTPUT in `convert w_p.png txt:|grep -oh "srgb([0-9]*,[0-9]*,[0-9]*)"`; do
  case "$OUTPUT" in
    # START DRAWING UP (AND FOLLOW INSTRUCTIONS WHEN REPLACING THE PIXELS)
    "srgb(7,84,19)") draw_up $i;;

    # START DRAWING LEFT (WE'VE SEEN THE PIXELS TOWARDS LEFT)
    "srgb(139,57,137)") draw_left $i;;

    # STOP DRAWING
    "srgb(51,69,169)") pixels[i]="@";;

    # TURN RIGHT
    "srgb(182,149,72)")
      if [[ i > 0 ]] && [ "${pixels[(( i - 1 ))]}" == "W" ];
      then
        # WE WERE GOING TO RIGHT AND TURNING RIGHT HERE MEANS THAT WE SHALL
        # CONTINUE DOWN BUT SINCE WE'VE YET TO ENCOUNTER THE INSTRUCTIONS 
        # WE MUST TELL OUR FUTURE SELVES TO HEAD DOWN FROM THIS PIXEL.
        pixels[(( i - 1 ))]="@";
        pixels[i]="D";
      elif [[ i > 179 ]] && [ "${pixels[(( i - ROW_LENGTH ))]}" == "D" ];
      then
        pixels[(( i - 180 ))]="@";
        draw_left $i;
      else
        # R TELLS US TO TURN RIGHT HERE WHEN WE END UP HERE IN THE FUTURE.
        pixels[i]="R";
      fi;;

    # TURN LEFT
    "srgb(123,131,154)") 
      if [[ i > 179 ]] && [ "${pixels[(( i - ROW_LENGTH ))]}" == "D" ]; then
        # PIXEL ABOVE THIS TOLD US TO HEAD DOWN AND TURNING LEFT MEANS
        # THAT WE MUST CONTINUE TO RIGHT BUT WE'VE NOT SEEN THE INSTRUCTIONS
        # IN THOSE PIXELS SO WE MARK THIS PIXEL WITH A W AND HANDLE IT LATER.
        pixels[(( i - ROW_LENGTH ))]="@";
        pixels[i]="W";
      else
        # L IS FOR 'TURN LEFT HERE'
        pixels[i]="L";
      fi;;

    # NO INSTRUCTIONS 
    *)
      if [ $i -eq 0 ]; then
        pixels[i]=" ";
      elif [ "${pixels[(( i - 1 ))]}" == "W" ]; then

        # CONTINUE TO RIGHT
        pixels[(( i - 1 ))]="@";
        pixels[i]="W";
      elif [ $i -lt $ROW_LENGTH ]; then
        pixels[i]=" ";
      elif [ "${pixels[(( i - ROW_LENGTH ))]}" == "D" ]; then

        # PIXEL ABOVE TOLD US TO GO DOWN
        pixels[(( i - ROW_LENGTH ))]="@";
        pixels[i]="D";
      else
        pixels[i]=" ";
      fi;;
  esac
  ((i++))
done

# 2) PRINT PIXELS 
for (( j=0; j<i; j++ )); do 
  if ! ((j % ROW_LENGTH)); then
    echo "${pixels[j]}"
  else
    echo -n "${pixels[j]}"
  fi
done
echo " "
