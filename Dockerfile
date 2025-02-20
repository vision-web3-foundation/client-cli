# SPDX-License-Identifier: GPL-3.0-only
FROM python:3.13-bookworm AS build

RUN apt-get update

RUN python3 -m pip install 'poetry<2.0.0'

WORKDIR /vision-cli

COPY . .

RUN make build

FROM python:3.13-bookworm AS production

WORKDIR /vision-cli

COPY --from=build /vision-cli/dist/*.whl .

RUN python3 -m pip install *.whl

RUN pip cache purge && rm -rf ~/.cache/pip

RUN rm *.whl

ENTRYPOINT ["vision-cli"]
