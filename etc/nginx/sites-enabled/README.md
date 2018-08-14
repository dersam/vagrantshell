# About wildcard vhosts in NGINX

`vagrantshell` makes use of wildcard domains for `nginx`. This means that in
order to start accessing a new project by domain name, simply create a
directory in `sites` with the corresponding domain name, and `nginx` will
automatically start serving it after a reload/restart. For example, create a
new directory called `foobar.test` in `sites`, add a hosts entry for that
exact domain name `192.168.70.70 foobar.test`, reload `nginx`, then point the
browser at that domain and all the content within that directory will be
served automatically, without need for additional configuration.

Note that under that directory name that corresponds with a domain name, the
`current` directory name underneath it is served by nginx. Files directly
underneath the domain name directory are outside of the Web root, which provides
a good place for sensitive configs that should be accessible only to the server
and not the public.

Note that going beyond `*.test` and `*.*.test` will not automatically support 
SSL. A new certificate will need to be generated to support, for example,
`*.*.*.test`. 

# Custom virtual hosts

If the default wildcard vhost configuration is not sufficient, you can still
create a new *.conf file in `nginx/sites-enabled/*.conf` with whatever specific
values required, and then add the corresponding directory in `sites`. This will
not have any impact on the way wildcard domains work. Odds are, this will
not need to be used, except for rare requirements.
