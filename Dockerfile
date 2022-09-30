FROM osgeo/proj:latest


RUN apt update -y && apt upgrade -y
RUN apt autoremove
RUN apt install -y unzip build-essential g++ proj-bin 
RUN apt install -y python3 python3-pip 
RUN apt install -y libwebp-dev
RUN mkdir /gdal
WORKDIR /gdal

COPY ECWJP2SDKSetup_5.5.0.1501-linux.zip /gdal
RUN unzip ECWJP2SDKSetup_5.5.0.1501-linux.zip
RUN chmod +x ECWJP2SDKSetup_5.5.0.1501.bin
RUN ./ECWJP2SDKSetup_5.5.0.1501.bin --accept-eula=yes --install-type=1
RUN cp -r ~/hexagon/ERDAS-ECW_JPEG_2000_SDK-5.5.0/Desktop_Read-Only /usr/local/hexagon
RUN rm -r /usr/local/hexagon/lib/x64
RUN mv /usr/local/hexagon/lib/cpp11abi/x64 /usr/local/hexagon/lib/x64
RUN cp /usr/local/hexagon/lib/x64/release/libNCSEcw* /usr/local/lib
RUN ldconfig /usr/local/hexagon

COPY gdal-3.5.2.tar.gz /gdal
RUN tar -xf gdal-3.5.2.tar.gz

WORKDIR /gdal/gdal-3.5.2/
RUN ./configure --enable-shared --with-python=python3 --with-proj=yes --with-ecw=/usr/local/hexagon 
RUN make clean
RUN make
RUN make install
RUN ln -s /usr/local/lib/libgdal.so.31 /usr/lib/libgdal.so.31

RUN pip install gdal pyproj webp
ENV PROJ_LIB=/usr/local/lib/python3.8/dist-packages/pyproj/proj_dir/share/proj
RUN gdalinfo --formats | grep ECW
RUN gdalinfo --formats | grep COG
RUN gdalinfo --formats | grep WEBP

WORKDIR /home
RUN rm -rf /gdal

ENTRYPOINT [ "/bin/bash" ]