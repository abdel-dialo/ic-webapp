ARG VERSION="3.6-alpine"
FROM python:$VERSION
ENV ODOO_URL="https://www.odoo.com"
ENV PGADMIN_URL="https://www.pgadmin.org" 
WORKDIR /opt
COPY ./requirements.txt .
COPY ./app.py .
COPY ./templates ./templates
COPY ./static ./static
RUN pip install flask==1.1.2
EXPOSE 8080
RUN pip install -r ./requirements.txt
EXPOSE 8080
CMD ["python", "app.py"]
