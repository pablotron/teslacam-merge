# teslacam-merge

Combine TeslaCam videos into a single output video.  Allows you to set
the output video size, and add a title to the output video.

Example:

```
# combine given videos, set the title to "sample video", and write the
# result to the file "sentry-example.mp4"
teslacam-merge -t 'sample video' -s 320x240 -o sentry-example.mp4 \
  2019-11-08_01-55-17-* 2019-11-08_01-48-14-{left,right}*.mp4
```
