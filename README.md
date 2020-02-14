Image optimizer docker images by Kernix
===============================
This docker will allow you to optimize jpeg and png images with the mogrify, pngquant and jpegtran conversion tools.


Dockerfiles
-----------

Dockerfiles are available at https://github.com/kernix/image-optimizer

Usage
-----

```
docker run --rm -v "/tmp/images:/var/www" kernix/image-optimizer:1.0 
```

When `/tmp/images` is the local images folder.

| Option | Description |
|---|---|
| --max-format | Max image format [WidthxHeight] (default = 1000x800) |
| --max-memory | Max memory usage (default : 2GiB) |
| --max-disc-space | Max disk space usage (default : 1GiB) |
| --jpg-quality | JPG quality (default : 85%) |
| --png-quality | PNG quality (default : 70-80) |
| -h -–help  | Script help |
| -f –-force | Force scripts for all without taking in considiration update time |

```
docker run --rm -v "/tmp/images:/var/www" kernix/image-optimizer:1.0 --max-format=1000x800 --png-quality=70-80 --jpg-quality=85% --max-memory=2GiB --max-disc-space=1GiB
```





 
     
     
     
     
      
      