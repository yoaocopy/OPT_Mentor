FROM node:lts


WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

#create models and libs directories
RUN mkdir /models
RUN mkdir /libs


WORKDIR /usr/src/app/models

RUN git clone https://huggingface.co/mlc-ai/Llama-3.2-1B-Instruct-q4f16_1-MLC
RUN git clone https://huggingface.co/mlc-ai/Llama-3.2-3B-Instruct-q4f16_1-MLC

WORKDIR /usr/src/app/libs

RUN wget "https://raw.githubusercontent.com/mlc-ai/binary-mlc-llm-libs/main/web-llm-models/v0_2_48/Llama-3.2-1B-Instruct-q4f16_1-ctx4k_cs1k-webgpu.wasm"
RUN wget "https://raw.githubusercontent.com/mlc-ai/binary-mlc-llm-libs/main/web-llm-models/v0_2_48/Llama-3.2-3B-Instruct-q4f16_1-ctx4k_cs1k-webgpu.wasm"

WORKDIR /usr/src/app

EXPOSE 5050

CMD [ "node", "app.js" ]