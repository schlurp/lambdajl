ARG JL_VERSION=1.1.1


## Stage 0 - Download and build Julia source code

FROM lambci/lambda:build-python3.7

ARG JL_VERSION

RUN mkdir /var/src \
 && cd /var/src \
 && git clone git://github.com/JuliaLang/julia.git

RUN yum install -y gcc-gfortran libgfortran \
 && cd /var/src/julia/contrib/ \
 && ./download_cmake.sh


RUN cd /var/src/julia \
 && [ $JL_VERSION == master ] || git checkout v$JL_VERSION

# Note LLVM build patch for https://github.com/JuliaLang/julia/issues/23462
COPY *.patch /var/src/julia/

RUN cd /var/src/julia \
 && for p in *.patch ; do patch -p0 < $p ; done

# Note, Lambda does not always run on HASWELL/AVX2:
# https://forums.aws.amazon.com/thread.jspa?messageID=802829#802829
ENV LAMBDAJL_MAKE \
        make VERBOSE=1 \
             prefix= \
             DESTDIR=/var/task \
             OPENBLAS_TARGET_ARCH=SANDYBRIDGE \
             MARCH=core-avx-i

RUN cd /var/src/julia \
 && $LAMBDAJL_MAKE -j4 julia-deps

RUN cd /var/src/julia \
 && $LAMBDAJL_MAKE -j4 \
 && $LAMBDAJL_MAKE install

ENV JULIA_PKGDIR=/var/task/julia \
    PATH=/var/task/bin:$PATH

RUN julia -e 'using Pkg; Pkg.update()'



## Stage 1 - Copy Julia installation into clean image

FROM lambci/lambda:build-python3.7

COPY --from=0 /var/task/ /var/task/
#COPY --from=0 /var/src/ /var/src/

ENV JULIA_PKGDIR=/var/task/julia \
    PATH=/var/task/bin:$PATH
