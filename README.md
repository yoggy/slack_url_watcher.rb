# slack_url_watcher.rb

```
  $ vi slack_url_watcher.rb

    ...modify $target_uri & $slack_webhook_url
  
  $ crontab -e

    3-59/10 * * * * /path/to/slack_uri_watcher.rb 2>&1

```
 
## Copyright and license
Copyright (c) 2022 yoggy

Released under the [MIT license](LICENSE.txt)
