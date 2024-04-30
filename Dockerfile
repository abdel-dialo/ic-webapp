FROM python:3.6-alpine
LABEL Abdoul Gadirou DIALLO <diallo.abdoulgadirou@gmail.com>
WORKDIR /opt
COPY ./app.py .
COPY ./templates ./templates
COPY ./static ./static
RUN pip install flask
EXPOSE 8080
ENV ODOO_URL="https://www.odoo.com"
ENV PGADMIN_URL="https://www.pgadmin.org"
RUN export ODOO_URL=$(awk '/ODOO_URL/ {sub(/^.* *ODOO_URL/,""); print $2}' releases.txt)
RUN export PGADMIN_URL=$(awk '/PGADMIN_URL/ {sub(/^.* *PGADMIN_URL/,""); print $2}' releases.txt)
ENTRYPOINT [ "python", "./app.py"]
