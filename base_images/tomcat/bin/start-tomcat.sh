#!/bin/bash
ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASS=${ADMIN_PASS:-tomcat}
MAX_UPLOAD_SIZE=${MAX_UPLOAD_SIZE:-52428800}

export CATALINA_OPTS="${CATALINA_OPTS:-"-Xms128m -Xmx1024m -XX:PermSize=128m -XX:MaxPermSize=256m"} -Djava.security.egd=file:/dev/./urandom"

# Convert the web api host and port to an allowed origin for grails cors
if [[ ${MDM_FQ_HOSTNAME} ]]
then
  # if host is set to * then all hosts allowed and thats the default
  if [[ ${MDM_FQ_HOSTNAME} != "*" ]]
  then
    allowOrigin='http'
    # if 443 then make https only
    if [[ ${MDM_PORT} -eq 443 ]]
     then
       allowOrigin="${allowOrigin}s"
    fi
    allowOrigin="${allowOrigin}://${MDM_FQ_HOSTNAME}"
    #if port not 80 or 443 then define in the allowed origin
    if [[ ${MDM_PORT} -ne 80 && ${MDM_PORT} -ne 443 ]]
    then
        allowOrigin="${allowOrigin}:${MDM_PORT}"
    fi
    export GRAILS_CORS_ALLOWEDORIGINS="${allowOrigin}"
  fi
fi


# Copy in admin user for the tomcat admin
cat << EOF > ${CATALINA_HOME}/conf/tomcat-users.xml
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
<user username="${ADMIN_USER}" password="${ADMIN_PASS}" roles="admin-gui,manager-gui"/>
</tomcat-users>
EOF

# Copy in the max upload size
if [ -f "${CATALINA_HOME}/webapps/manager/WEB-INF/web.xml" ]
then
	sed -i "s#.*max-file-size.*#\t<max-file-size>${MAX_UPLOAD_SIZE}</max-file-size>#g" ${CATALINA_HOME}/webapps/manager/WEB-INF/web.xml
	sed -i "s#.*max-request-size.*#\t<max-request-size>${MAX_UPLOAD_SIZE}</max-request-size>#g" ${CATALINA_HOME}/webapps/manager/WEB-INF/web.xml
fi

# Start Tomcat
>&2 echo "Starting Tomcat"
catalina.sh run

