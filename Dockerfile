# Pull base image
FROM python:3.10-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /code

# Install dependencies
# COPY Pipfile Pipfile.lock /code/
RUN apt-get update
RUN apt-get install -y apt-utils vim curl apache2 apache2-utils
RUN apt-get -y install libapache2-mod-wsgi-py3
RUN python -m venv venv
RUN pip install --upgrade pip
RUN pip install setuptools==60.10.0
COPY requirements/* requirements/
CMD . venv/bin/activate
RUN pip install -r requirements/base.txt
#RUN pip install rdmo environs
RUN pip install -r requirements/postgres.txt

# Copy project
COPY . /code/
# Apache
ADD ./rdmo_site.conf /etc/apache2/sites-available/rdmo_site.conf
RUN a2ensite rdmo_site.conf
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod proxy_balancer
RUN a2enmod lbmethod_byrequests
RUN service apache2 start
# RUN service apache2 reload

# static files
RUN python manage.py download_vendor_files
RUN python manage.py collectstatic --noinput --clear

EXPOSE 80 3500
CMD ["apache2ctl", "-D", "FOREGROUND"]
