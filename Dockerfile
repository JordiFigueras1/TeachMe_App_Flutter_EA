# Usar la imagen oficial de Flutter 3.24
FROM fischerscode/flutter:flutter-3.24-candidate.0

# Cambiar al usuario root para instalar dependencias
USER root

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Instalar git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clonar el repositorio desde GitHub
RUN git clone https://github.com/JordiFigueras1/TeachMe_App_Flutter_EA.git .

# Ajustar permisos del directorio para el usuario 'flutter'
RUN chown -R flutter:flutter /app

# Cambiar nuevamente al usuario predeterminado de la imagen
USER flutter

# Permitir la ejecucion de Flutter como root
RUN echo "allow-root=true" >> /home/flutter/.flutter_settings

# Instalar las dependencias de Flutter
RUN flutter pub get

# Exponer el puerto para la ejecucion del frontend
EXPOSE 51139

# Comando para ejecutar la aplicacion
CMD ["flutter", "run", "-d", "web-server", "--web-port", "51139", "--web-hostname", "0.0.0.0"]