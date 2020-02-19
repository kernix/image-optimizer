#! /bin/bash

# Usage: to call the script you need
# sh image-optimizer.sh /var/www/images

WORK_DIR='.';

# Reference and Lock files
LOCK_FILE='image-optimizer.lock';
REFERENCE_FILE='image-optimizer.ref';

# Max width and max height you allow, it will resize all image with width > 1000 or height > 800
# and maintain aspect ratio
MAX_SIZE='1000x800';
# PNG quality settings, range btw your requirements
PNG_QUALITY='';
# JPG quality settings
JPG_QUALITY='';
# Max memory size
MAX_MEMORY='2GiB';
# Max disk space size
MAX_DISK_SPACE='1GiB';
# Force all image without time update
FORCE=0;


#———————————————————————– help –
# Display Script help syntax
#
display_help() {
  echo ""
  echo "Usage: image-optimizer <images_directory> [ --max-size | --max-memory | --max-disc-space | --jpg-quality | --png-quality | –h | –f ]"
  echo ""
  echo "  Optional:"
  echo "    --max-size Max image size [WidthxHeight] (default = 1000x800)"
  echo "    --max-memory Max memory usage (default : 2GiB)"
  echo "    --max-disc-space Max disk space usage (default : 1GiB)"
  echo "    --jpg-quality JPG quality to optimize JPG/JPEG (ex. : 85)"
  echo "    --png-quality PNG quality to optimize PNG (ex. : 70-80)"
  echo "    -h -–help   Script help"
  echo "    -f –-force  Force scripts for all without taking in considiration update time"
  echo ""
  exit 0
}

#————————————————————– log –
# Log a message
#
log() {
  echo "[$(date --rfc-3339=seconds)]: $*"
}

#————————————————————– process_args –
# Process Command Line Arguments
#
process_args() {
  if [ -z "$1" ]; then
    echo "------- You need to set the path of the folder as argument -------";
    exit 1;
  else
    WORK_DIR="$1";
  fi

  for i in "$@"
  do
  case $i in
    --max-size=*)
    MAX_SIZE="${i#*=}"
    ;;
    --png-quality=*)
    PNG_QUALITY="${i#*=}"
    ;;
    --jpg-quality=*)
    JPG_QUALITY="${i#*=}"
    ;;
    --max-memory=*)
    MAX_MEMORY="${i#*=}"
    ;;
    --max-disc-space=*)
    MAX_DISK_SPACE="${i#*=}"
    ;;
    -f | --force)
    FORCE=1
    ;;
    -h | --help)
    display_help
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
     # unknown option
    ;;
  esac
  done
}

#————————————————————– optimize –
# Optimize images files
#
optimize() {
  if [ ! -f $REFERENCE_FILE ]; then
    # Create REFERENCE_FILE with old timestamp to process everything the first time
    touch $REFERENCE_FILE -d 1970101
  fi

  if [ -f $LOCK_FILE ]; then
      # Task locked
      log "The task is already running !";
  else
    # lock task to avoid double execution
    touch $LOCK_FILE;

    if [ "$FORCE" -eq "0" ]; then
      log  "Processing only modified from last 24h images for folder $WORK_DIR ....";
      # Resize image dimension, rules are as follow:
      # if image width > max_width, resize to max_width width keep aspect ratio
      # if image height > max_height, resize to max_height height keep aspect ratio
      log "Processing resize ....";
      find $WORK_DIR -type f -iname '*.png'  -mtime -1 -newer $REFERENCE_FILE -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_SIZE\> -verbose {} +;
      find $WORK_DIR -type f -iname '*.jpg'  -mtime -1 -newer $REFERENCE_FILE -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_SIZE\> -verbose {} +;
      find $WORK_DIR -type f -iname '*.jpeg' -mtime -1 -newer $REFERENCE_FILE -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_SIZE\> -verbose {} +;

      # Optimize jpg and jpeg encoding
      log "Processing JPG/JPEG optimization ....";
      find $WORK_DIR -type f -iname '*.jpg'  -mtime -1 -newer $REFERENCE_FILE -printf "%h/%f\n" -exec jpegtran -copy none -optimize -perfect -outfile {} {} \;
      find $WORK_DIR -type f -iname '*.jpeg' -mtime -1 -newer $REFERENCE_FILE -printf "%h/%f\n" -exec jpegtran -copy none -optimize -perfect -outfile {} {} \;

      # Optimize png with quality if PNG_QUALITY seted
      if [ ! -z "$PNG_QUALITY" ]; then
        log "Processing PNG quality ($PNG_QUALITY%) ....";
        find $WORK_DIR -type f -iname '*.png'  -mtime -1 -newer $REFERENCE_FILE -exec pngquant --verbose -f --ext .png --quality=$PNG_QUALITY --skip-if-larger {} \;
      fi

      # Optimize png with quality if JPG_QUALITY seted
      if [ ! -z "$JPG_QUALITY" ]; then
        log "Processing JPG/JPEG quality ($JPG_QUALITY%) ....";
        find $WORK_DIR -type f -iname '*.jpg'  -mtime -1 -newer $REFERENCE_FILE -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -quality $JPG_QUALITY% -verbose {} +;
        find $WORK_DIR -type f -iname '*.jpeg' -mtime -1 -newer $REFERENCE_FILE -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -quality $JPG_QUALITY% -verbose {} +;
      fi
    else
      log "Processing all images for folder $WORK_DIR (force actived) ....";
      find $WORK_DIR -type f -iname '*.png'  -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_SIZE\> -verbose {} +;
      find $WORK_DIR -type f -iname '*.jpg'  -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_SIZE\> -verbose {} +;
      find $WORK_DIR -type f -iname '*.jpeg' -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_SIZE\> -verbose {} +;

      # Optimize jpg and jpeg encoding
      log "Processing JPG/JPEG optimization ....";
      find $WORK_DIR -type f -iname '*.jpg'  -printf "%h/%f\n" -exec jpegtran -copy none -optimize -perfect -outfile {} {} \;
      find $WORK_DIR -type f -iname '*.jpeg' -printf "%h/%f\n" -exec jpegtran -copy none -optimize -perfect -outfile {} {} \;

      # Optimize png with quality if PNG_QUALITY seted
      if [ ! -z "$PNG_QUALITY" ]; then
        log "Processing PNG quality ($PNG_QUALITY%) ....";
        find $WORK_DIR -type f -iname '*.png'  -exec pngquant --verbose -f --ext .png --quality=$PNG_QUALITY --skip-if-larger {} +;
      fi

      if [ ! -z "$JPG_QUALITY" ]; then
        log "Processing JPG/JPEG quality ($JPG_QUALITY%) ....";
        find $WORK_DIR -type f -iname '*.jpg'  -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -quality $JPG_QUALITY% -verbose {} +;
        find $WORK_DIR -type f -iname '*.jpeg' -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -quality $JPG_QUALITY% -verbose {} +;
      fi

    fi


    # Update REFERENCE FILE timestamp so next time we process only diff
    touch $REFERENCE_FILE;

    # Unlock the task
    rm $LOCK_FILE;
  fi
}

#———————————————————————– main –
# Main Script Processing
#
main () {
  log "Start optimizer ...."
  process_args "$@"
  optimize
  log "End optimizer."
}

main "$@"
