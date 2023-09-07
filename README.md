# daily-shutdown
An EC2 script to shutdown my machine based on inactivity.

## Activation

I run the script out of cron. You will want to adjust the hours based on your timezone. I also usually include the guide below so I can remember the right fields for cron. And I include 2 variables. Setting MAILTO="" will remove the mail process for any cron failures. And CRON="1" I use in my scripts to change the output if they are running within cron.

    CRON="1"
    MAILTO=""
    # Run Backup Script Nightly at 1am
    #0 1 * * *  /home/ubuntu/scripts/rbackup
    #| | | | |
    #| | | | +-- day of week 0-7 (0 or 7 is Sun, or use names)
    #| | | +-- month 1-12 (or names, see crontab (5))
    #| | +-- day of month 1-31
    #| +-- hour 0-23
    #+-- minute 0-59
    */15 15-23 * * * /home/ubuntu/scripts/daily-shutdown.sh
    */15 00-05 * * * /home/ubuntu/scripts/daily-shutdown.sh

## Configuration

There are 2 basic variables required for the script to run

    TUSER="ubuntu"
    IDLEMIN="15"

TUSER is the user that the script will look for. This was taken from an ubuntu machine. Amazon Linux uses ec2-user.
And the IDLEMIN is the Idle Minutes to look for. Here it's set for 15 minutes.

## Disable for specific date range

I also created an option to tell the script to NOT turn off the instance during a specific timeframe (days). This will be configured in this file:

    CONFIG="/home/$TUSER/.$( basename "$0" )"

And the contents of the file look like:

    NOOFF="Nov 19, 2023 - Dec 4, 2023"

So here it will not shutdown between Nov 19th and Dec 4th of 2023.
    
