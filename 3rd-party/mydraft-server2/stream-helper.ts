import { Writable } from 'stream'

export module utils {
    export function writeAsync(stream: Writable, chunk: any) {
        return new Promise((resolve, reject) => {
            stream.write(chunk, error => {
                if (error) {
                    reject(error);
                } else {
                    resolve(true);
                }
            });
        });
    }
    export function endAsync(stream: Writable) {
        return new Promise((resolve) => {
            stream.end(undefined, () => {
                resolve(true);
            });
        });
    }
}
