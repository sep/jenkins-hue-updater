# Bash bridge for Jenkins/Hue

I wanted to set up a small GNU/Linux machine (or, you know, whatever. A Raspberry Pi. Something) to handle the job of analyzing our builds and updating our Hue lights. But to do so I would have to write some scripts to manage the polling of Jenkins and the updating of the Hues.

So I wrote that. And this is that.

I chose Bash because it's pretty common across Linux systems. And other Unixy systems. And even Windows sometimes.

## How to use

First, copy all of the scripts to some directory. In our build ecosystem I've installed Mint on a HP puck-like device (PLD) and copied the scripts to `/home/user/light-scripts`.

Next, write a configuration file in JSON:

```javascript
{
    "jenkinsViewUrl": "http://example.com/JenkinsView/api/json",
    "hueLightStateUrl": "http://example.com/hue/lights/1/state",
    "colors": {
        "bad": 123,
        "good": 234,
        "building": 345,
        "badAndBuilding": 456,
        "unstable": 567
    },
    "saturation": 111,
    "brightness": 222
}
```

* `jenkinsViewUrl` points to the Jenkins view that holds all the builds you want to monitor
* `hueLightStateUrl` points to your Hue bridge - specifically, the `state` for your light
* `colors` is an object that holds Hue color values for each of the five light states
* `saturation` is the Hue value for saturation (0-255)
* `brightness` is the Hue value for brightness (0-255)

The build states are:

* `good`: every single build collected in your Jenkins view is passed
* `bad`: at least one build collected in your Jenkins view is failed
* `building`: at least one build collected in your Jenkins view is building, and the others are passed
* `badAndBuilding`: at least one build collected in your Jenkins view is building, and at least one is failed
* `unstable`: at least one build collected in your Jenkins view is unstable, and the rest are passing

## Colors

Guys, I tried to find a good article or tool to help you pick your color values for Hue bulbs, but... man, your'e on your own. Just run `./hue_updater.sh --good-color ${integer between 0 and, like, 60000} GOOD ${hueLightStateUrl}` and experiment.

## CRON!

The whole reason I wrote this in Bash was so I could use `cron` to poll the Jenkins server and update the Hue bulb. You can do so like this:

`sudo crontab -e`

And then add the following `cron` rule:

`* * * * * /home/user/run.sh /home/user/my-config.json >> /var/log/hue-update.log 2>&1`

Save and exit!

## Testing

You can also run the commands individually to see if the various components are working:

... `./jenkins_parser.sh "http://example.com/JenkinsView/api/json"`

should show you the current aggregated state of the builds in your view. You can use:

`./hue_updater.sh --good-color 0 GOOD "http://example.com/hue/lights/1/state"`

... to turn your light red.

## Also TDD!

To test-drive this code I used [`BATS`](https://github.com/sstephenson/bats) which was totally fun. I highly recommend you peruse the `tests` folder and take a look.

## License

BSD
