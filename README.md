Belkin-WeMo-Twilio-Server
=========================

Home automation example using Belkin Wemo Perl APIs and controlling through SMS via Twilio and Siri voice control.  See the full article at http://eric-blue.com/2013/12/31/home-automation-with-belkin-wemo-twilio-and-siri/

Step by Step Instructions

[API and SMS server]

1. Find a computer located on the same network as your Belkin Devices.  
2. Ensure your firewall/router can open up port 9000 (default) and map to your computer.
3. Check out the Perl Belkin Wemo API from CPAN (v1.0 as of this writing) for the latest stable version, or Github for the latest developments.
4. Scan your local network to find all Belkin Wemo Switches and save into your /etc/belkin.db file (see examples/scan.pl under the Perl Wemo API dist)
5. Create a simple test script to turn a switch on and off to make sure things are working OK
6. Download the SMS server example at https://github.com/ericblue/Belkin-WeMo-Twilio-Server.  The commands, your cell number, and the names of your switches should be changed.
You can launch the server (launch.sh) or in debug mode.  Going to http://your_internal_ip:9000/ should show a simple text welcome message.

[Twilio Setup]

1. Go to http://twilio.com and setup an account (Note: this is NOT free, but the cost is minimal for sending/receiving calls and texts)
2. Register a new number and define the messaging request url as ‘http://your_public_ip:9000/sms/ and POST.  Port 9000 is the default port, and should be mapped in your firewall from your public IP to internal IP of your SMS server.
3. Send a text/SMS message to this computer ‘get devices’ and you should get a list of all Belkin Switches on your Network

[iPhone/Siri for Voice Control]

1. See this article on setting up Siri for voice control - http://www.dummies.com/how-to/content/how-to-use-siri-for-texting.html
2. Add your Twilio SMS server as a contact.  I named mine ‘Computer’ (think Star Trek :) , but you can name it whatever you want
3. You’ll need to add a nickname or relationship/label as ‘Computer’ so when you hold down the button for Siri you can say ‘text Computer <say command here>’
Example commands:

If you look at the sms_server.pl file you can see it’s a VERY simple and crude processor for some basic commands and translates words such as ‘upstairs’ and ‘downstairs’ to specific devices.  This was created very quickly, so to customize you could modify to suit your needs or add something more sophisticated like a rule processor or XML-based config for mapping commands and devices.

That’s it!  I hope you enjoyed this relatively simple hack and have fun!


