# Video Downloader with yt-dlp

## Overview

This guide explains how to set up and use `yt-dlp` for downloading videos from websites that require authentication.

## Prerequisites

1. **Create a Virtual Environment**  
   To isolate your project dependencies, create a virtual environment:

   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On macOS/Linux
   # On Windows, use: .venv\Scripts\activate
   ```

2. **Install yt-dlp**  
   Install `yt-dlp` along with its required dependencies:

   ```bash
   pip install "yt-dlp[default,curl-cffi]"
   ```

## Obtaining Cookies

To download videos from sites that require authentication, you need to obtain cookies:

1. Use a browser extension like [Get cookies.txt](https://chrome.google.com/webstore/detail/get-cookiestxt/bgaddcpmklkifnbgmcofdifmbnoclpb) for Chrome to export cookies.
2. Navigate to the website hosting the video you want to download.
3. Export the cookies using the extension and save the file as `cookies.txt` in the same folder as your script.

## Downloading Videos

Use the following command to download the video, replacing the URL with the desired video link:

```bash
yt-dlp -f bestvideo+bestaudio --cookies cookies.txt --retry-sleep 3 --retries 10 --no-overwrites --concurrent-fragments 10 "https://example.com"
```

### Explanation of Flags

- `-f bestvideo+bestaudio`: Downloads the best available video and audio quality.
- `--cookies cookies.txt`: Specifies the cookies file for authenticated access.
- `--retry-sleep 3`: Waits 3 seconds before retrying in case of failure.
- `--retries 12`: Makes up to 10 retries for failed downloads.
- `--no-overwrites`: Prevents overwriting existing files.
- `--concurrent-fragments 20`: Sets the number of concurrent downloads for a single video fragment. A value of 10 provides a good balance between speed and server restrictions. Increasing it may improve speed but could lead to issues if the server enforces limits.

## Additional Tips

- **Customizing URL:** Replace `https://example.com` with the URL of the video you want to download.
- **Troubleshooting:** If the server rejects requests or imposes bans, reduce the value of `--concurrent-fragments`.

## Folder Structure Example

```bash
project-folder/
|-- .venv/
|-- cookies.txt
|-- script.sh  # Optional script file
```
