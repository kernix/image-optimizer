#! /bin/bash

# Usage: to call the script you need
# sh image-optimizer.sh /var/www/images

WORK_DIR='.';

# Log and Lock files
LOCK_FILE='image-optimizer.lock';
LOG_FILE='image-optimizer.log';

# Max width and max height you allow, it will resize all image with width > 1000 or height > 800
# and maintain aspect ratio
MAX_FORMAT='1000x800';
# PNG quality settings, range btw your requirements
PNG_QUALITY='70-80';
# JPG quality settings
JPG_QUALITY='85%';
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
  echo "Usage: image-optimizer <images_directory> [ --max-format | --max-memory | --max-disc-space | --jpg-quality | --png-quality | –h | –f ]"
  echo ""
  echo "  Optional:"
  echo "    --max-format Max image format [WidthxHeight] (default = 1000x800)"
  echo "    --max-memory Max memory usage (default : 2GiB)"
  echo "    --max-disc-space Max disk space usage (default : 1GiB)"
  echo "    --jpg-quality JPG quality (default : 85%)"
  echo "    --png-quality PNG quality (default : 70-80)"
  echo "    -h -–help   Script help"
  echo "    -f –-force  Force scripts for all without taking in considiration update time"
  echo ""
  exit 0
}

#————————————————————– process_args –
# Process Command Line Arguments
#
process_args() {
  echo "$@"
  if [ -z "$1" ]; then
    echo "------- You need to set the path of the folder as argument -------";
    exit 1;
  else
    WORK_DIR="$1";
  fi

  for i in "$@"
  do
  case $i in
    --max-format=*)
    MAX_FORMAT="${i#*=}"
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
  if [ ! -f $LOG_FILE ]; then
    # Create LOG_FILE with old timestamp to process everything the first time
    touch $LOG_FILE -d 1970101
	fi

	if [ -f $LOCK_FILE ]; then
			# Task locked
			echo "------- The task is already running -------"
	else
		# lock task to avoid double execution
		touch $LOCK_FILE;

		DATE_START=$(date '+%d/%m/%Y %H:%M:%S');

		echo "";
		echo "-----------------------------------------------";
		echo "Start at $DATE_START";
		echo "";

		if [ "$FORCE" -eq "1" ]; then
			echo "Process only modified from last 24h images for folder $WORK_DIR";
			# Resize image dimension, rules are as follow:
			# if image width > 1000px, resize to 1000px width keep aspect ratio
			# if image height > 800px, resize to 800px height keep aspect ratio
			find $WORK_DIR -type f -iname '*.png'  -mtime -1 -newer $LOG_FILE -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_FORMAT\> {} +;
			find $WORK_DIR -type f -iname '*.jpg'  -mtime -1 -newer $LOG_FILE -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_FORMAT\> {} +;
			find $WORK_DIR -type f -iname '*.jpeg' -mtime -1 -newer $LOG_FILE -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_FORMAT\> {} +;

			# Optimize png with quality set in pngQuality var
			find $WORK_DIR -type f -iname '*.png'  -mtime -1 -newer $LOG_FILE -exec pngquant -f --ext .png --quality=$PNG_QUALITY --skip-if-larger {} \;
			# Optimize jpg and jpeg encoding
			find $WORK_DIR -type f -iname '*.jpg'  -mtime -1 -newer $LOG_FILE -exec jpegtran -copy none -optimize -perfect -outfile {} {} \;
			find $WORK_DIR -type f -iname '*.jpeg' -mtime -1 -newer $LOG_FILE -exec jpegtran -copy none -optimize -perfect -outfile {} {} \;
			# Optimize jpg with quality set in jpgQuality var
			#find $WORK_DIR -type f -iname '*.jpg' -mtime -1 -newer $referenceFile -exec mogrify -limit memory $maxMemory -limit disk $maxDiskSpace -interlace Plane -gaussian-blur 0.05 -quality $jpgQuality {} +;
			#find $WORK_DIR -type f -iname '*.jpeg' -mtime -1 -newer $referenceFile -exec mogrify -limit memory $maxMemory -limit disk $maxDiskSpace -interlace Plane -gaussian-blur 0.05 -quality $jpgQuality {} +;
	  else
			echo "Process all images for folder $WORK_DIR";
			find $WORK_DIR -type f -iname '*.png'  -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_FORMAT\> {} +;
			find $WORK_DIR -type f -iname '*.jpg'  -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_FORMAT\> {} +;
			find $WORK_DIR -type f -iname '*.jpeg' -exec mogrify -limit memory $MAX_MEMORY -limit disk $MAX_DISK_SPACE -resize $MAX_FORMAT\> {} +;

			find $WORK_DIR -type f -iname '*.png'  -exec pngquant -f --ext .png --quality=$PNG_QUALITY --skip-if-larger {} +;
			find $WORK_DIR -type f -iname '*.jpg'  -exec jpegtran -copy none -optimize -perfect -outfile {} {} \;
			find $WORK_DIR -type f -iname '*.jpeg' -exec jpegtran -copy none -optimize -perfect -outfile {} {} \;
			#find $WORK_DIR -type f -iname '*.jpg' -newer $referenceFile -exec mogrify -limit memory $maxMemory -limit disk $maxDiskSpace -interlace Plane -gaussian-blur 0.05 -quality $jpgQuality {} +;
			#find $WORK_DIR -type f -iname '*.jpeg' -newer $referenceFile -exec mogrify -limit memory $maxMemory -limit disk $maxDiskSpace -interlace Plane -gaussian-blur 0.05 -quality $jpgQuality {} +;
		fi

		DATE_END=$(date '+%d/%m/%Y %H:%M:%S');
		echo "";
		echo "end at $DATE_END";
		echo "-----------------------------------------------";
		echo "";

		# Update LOG FILE timestamp so next time we process only diff
		touch $LOG_FILE;

		# Unlock the task
		rm $LOCK_FILE;
  fi
}

#———————————————————————– main –
# Main Script Processing
#
main () {
  process_args "$@"
  optimize
}

main "$@"
