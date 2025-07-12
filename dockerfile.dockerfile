FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y g++ apache2 apache2-utils && \
    apt-get clean

# Enable CGI
RUN a2enmod cgi

# Setup web root
WORKDIR /var/www/html
COPY . /var/www/html

# Move your CGI file to cgi-bin and give execution permissions
RUN mkdir -p /usr/lib/cgi-bin
RUN g++ -o /usr/lib/cgi-bin/trie.cgi trie.cpp
RUN chmod +x /usr/lib/cgi-bin/trie.cgi

# Configure Apache to handle .cgi
RUN echo "ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/" >> /etc/apache2/apache2.conf
RUN echo "<Directory \"/usr/lib/cgi-bin\">" >> /etc/apache2/apache2.conf
RUN echo "    AllowOverride None" >> /etc/apache2/apache2.conf
RUN echo "    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch" >> /etc/apache2/apache2.conf
RUN echo "    Require all granted" >> /etc/apache2/apache2.conf
RUN echo "</Directory>" >> /etc/apache2/apache2.conf

EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]
