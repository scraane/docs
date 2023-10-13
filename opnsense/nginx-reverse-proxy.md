Step 1: Installation
You need to install the nginx and lets-encrypt plugins.

After that, configure you’re letsencrypt so that you get a valid SSL certificate for your service.
You need to use DNS-01 validation method, because nginx will use the port 80, and the lets-encrypt plugin is not able to use the modify the Nginx configuration for a successful validation.
When youre done, you can continue to Step 2.
(You can also use official paid certificates, if you have one, you need to import the CA, Cert and Key unter System → Trust)


Step 2: Configure Nginx

You need to be sure, that your OPNsense is not using port 80 or 443.
So you need to change the default port of your OPNsense webgui.
This can be done under “System → Settings → Administration”.
You also need to disable the HTTP Redirect.
Restart your firewall when done.

From now on, all steps are meant to configure under Services →Nginx → Configuration

2.1 Configure the upstream server

First of all, you need to configure your upstream server, this is the real server, where your web application runs on.
This could be any host on your LAN, DMZ or whatever.

To do so, navigate to Upstream → Upstream Server and click on the + in the right bottom corner.
Now enter a description, IP and port (80 – HTTP in most cases).
Use 1 as Server priority.

2.2 Configure the upstream
Next you need to configure the upstream, where you link your created upstream server.
You need to do that, because you could also configure multiple servers, for the same upstream for load balancing.
So what we configure, is a “load balancer” with just one host.

Therefore navigate to Upstream → Upstream and create one.
Chose a description, and link the upstream server you just created.
As load balancing algorithm, use weighted round robin.
Leave the rest as it is, if you don’t use HTTPS directly on your upstream server.


2.3 Configure the Location
As the next step, you need to configure the Location (URL) of your web application.
Navigate to HTTP(S) → Location and click on Add.
As URL Pattern, just use slash (/) and match type none.
URL rewriting should be nothing.
Define the Upstream server you created before and leave the rest as it is for now.

Later, you can configure the Web Application Firewall rule here.


2.4 Configure HTTP Server
The last step, to bring your web application online, is to configure the HTTP Server.
Navigate to HTTP(s) → HTTP Server and click on Add.
This should match your need in most cases:

HTTP Listen Port: 80
HTTPS Listen Port: 443
Server Name: The URL your applications listens to (for example: cloud.domain.com)
Locations: the location created in step 2.3
URL Rewriting: Nothing selected
TLS Certificate: The issued Lets-Encrypt or imported certificate for this host

Leave the rest as it is for now.

2.5 Apply changes
When your done, click on General Settings and then on Apply
Your nginx should now be ready to server your web application.
Be sure to have correct firewall rules (from wan to this device, port 80 & 443)
