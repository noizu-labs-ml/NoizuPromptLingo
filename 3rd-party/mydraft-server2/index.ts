import 'dotenv/config'
import { Database } from '@hocuspocus/extension-database';
import { Logger } from '@hocuspocus/extension-logger';
import { Server } from '@hocuspocus/server';
import { Bucket, Storage } from '@google-cloud/storage';
import { utils } from './stream-helper'
import cors from 'cors';
import express from 'express';
import expressWebsockets from 'express-ws';
import ShortUniqueId from 'short-unique-id';
import fileStore from './fileStore';
import path from 'node:path';

const uid = new ShortUniqueId({ length: 20 });
const serverPort = parseInt(process.env.SERVER_PORT || '8080');

let storageBucket: Bucket | typeof fileStore;
if (process.env.STORAGE_TYPE === "local") {
    storageBucket = fileStore
} else {
    const storageClient = new Storage();
    storageBucket = storageClient.bucket(process.env.STORAGE_GCP_BUCKET_NAME || 'athene-diagram-files');
}

const server = Server.configure({
    extensions: [
        new Database({
            fetch: async ({ documentName }) => {
                const file  = storageBucket.file(`collaboration/${documentName}`);
                
                const [exists] = await file.exists();
                if (!exists) {
                    return null;
                }

                const buffers = await file.download();

                return Buffer.concat(buffers);
            },
            store: async ({ documentName, state }) => {
                const file  = storageBucket.file(`collaboration/${documentName}`);

                const stream = file.createWriteStream();

                await utils.writeAsync(stream, state);
                await utils.endAsync(stream);
            },
        }),
        new Logger({
            onChange: false
        }),
    ]
});

const { app } = expressWebsockets(express());

app.use(cors());
app.use(express.json());

app.get('/api/health', (_, response) => {
    response.send({
        status: 'Healthy'
    });
});

app.ws('/api/collaboration', (websocket, request) => {  
    server.handleConnection(websocket, request, {});
});

app.get('/api/:tokenRead', async (request, response) => {
    const file  = storageBucket.file(request.params.tokenRead);

    const [exists] = await file.exists();
    if (!exists) {
        response.status(404);
        return;
    }

    response.setHeader('Content-Type', 'application/json');

    file.createReadStream().pipe(response);
});

app.post('/api/', async (request, response) => {
    const tokenWrite = uid.rnd();
    const tokenRead = uid.rnd();

    const file  = storageBucket.file(tokenRead);

    await file.save(JSON.stringify(request.body, undefined, 2), {
        metadata: {
            contentType: 'application/json',
            contentLength: undefined,
            'write-token': tokenWrite
        }
    });

    return response.status(201).json({ readToken: tokenRead, writeToken: tokenWrite });
});

app.put('/api/:tokenRead/:tokenWrite', async (request, response) => {
    const tokenWrite = request.params.tokenWrite;
    const tokenRead = request.params.tokenRead;

    const file  = storageBucket.file(request.params.tokenRead);

    const [exists] = await file.exists();
    if (!exists) {
        response.status(404);
        return;
    }

    const [metadata] = await file.getMetadata();
    
    if (metadata['write-token'] !== request.params.tokenWrite) {
        response.status(403);
        return;
    }

    await file.save(JSON.stringify(request.body, undefined, 2));

    return response.status(201).json({ readToken: tokenRead, writeToken: tokenWrite });
});

app.use(express.static(path.join(__dirname, './ui/dist'), {}))
app.get('/*', function(req, res) {
    res.sendFile(path.join(__dirname, './ui/dist/index.html'));
});

app.listen(Number(serverPort), () => console.log(`Listening on http://127.0.0.1:${serverPort}`));