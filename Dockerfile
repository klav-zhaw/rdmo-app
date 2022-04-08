# Pull base image
FROM python:3.10-bullseye-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /code

# Install dependencies
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

# static files
RUN python manage.py download_vendor_files
RUN python manage.py collectstatic --noinput --clear

EXPOSE 80 8000
